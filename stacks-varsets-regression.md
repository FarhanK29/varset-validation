# Stacks + Variable Sets — Regression Test Guide

Six focused regression scenarios for testing variable set behaviour on Terraform Stacks.
Each test case includes a complete setup, step-by-step instructions, the Terraform
configuration required to reproduce it, and the expected outcome.

---

## Prerequisites

- A Stacks-enabled HCP Terraform organization
- The [Terraform CLI](https://developer.hashicorp.com/terraform/install) (version 1.10 or later, which includes Stacks support)
- A GitHub (or other VCS) repository you can push to, connected to HCP Terraform — **or** a Stack configured for manual (API-driven) uploads
- Owner or admin-level permissions in the organization

---

## Part 1 — Create the shared Terraform stack repository

All six test cases use the same repository. Create it once before running any test case.

### Step 1 — Create the repository

Create a new empty repository on GitHub (or your VCS provider) named `varset-regression-stack`.

If you prefer not to use VCS, you can instead create a Stack configured for **manual** (API-driven) uploads and `tar` upload the directory manually — see [Part 3](#part-3--connect-the-repository-to-a-stack-in-hcp-terraform) for the alternative.

---

### Step 2 — Create the directory structure

On your local machine, create the following layout and add each file shown below:

```
varset-regression-stack/
├── .terraform-version
├── .terraform.lock.hcl
├── main.tfcomponent.hcl
├── deployments.tfdeploy.hcl
└── app/
    └── main.tf
```

---

#### `.terraform-version`

Pins the Terraform version used by the agent. Use the latest stable version that supports Stacks:

```
1.15.5
```

---

#### `app/main.tf`

This is the Terraform module the stack component calls. It accepts two input variables and
exposes them as outputs so you can verify the correct values were resolved during a run.
It uses `hashicorp/random` so no cloud credentials are required.

```hcl
terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9.0"
    }
  }
}

variable "region" {
  type        = string
  description = "Simulated deployment region — sourced from a varset store"
}

variable "environment" {
  type        = string
  default     = "unknown"
  description = "Simulated environment name — sourced from a varset store"
}

# Use the variable in a resource so Terraform actually does work with it
resource "random_string" "label" {
  length  = 8
  special = false
  upper   = false
  keepers = {
    region      = var.region
    environment = var.environment
  }
}

output "region_out" {
  value       = var.region
  description = "The region value that was passed in — verify this matches your varset"
}

output "environment_out" {
  value       = var.environment
  description = "The environment value that was passed in — verify this matches your varset"
}
```

---

#### `main.tfcomponent.hcl`

This is the stack-level component definition. It declares the `random` provider, references
the `app` module, and wires the component inputs from a `store "varset"` block.

The `store "varset" "my-varset"` block is left with a placeholder comment — **you will
fill in either `id` or `name` in each individual test case**.

```hcl
required_providers {
  random = {
    source  = "hashicorp/random"
    version = "~> 3.9.0"
  }
}

provider "random" "this" {}

component "app" {
  source = "./app"

  providers = {
    random = provider.random.this
  }

  inputs = {
    region      = store.varset.my-varset.region
    environment = store.varset.my-varset.environment
  }
}

# Fill in `name` or `id` for each test case before pushing
store "varset" "my-varset" {
  # name = "tc1-stack-varset"
}
```

---

#### `deployments.tfdeploy.hcl`

Defines a single `production` deployment. Test Case 6 will extend this file with a second
`staging` deployment — instructions for that change are in the test case itself.

```hcl
deployment "production" {
  inputs = {}
}
```

---

#### `.terraform.lock.hcl`

Generate this file by running `terraform stacks providers-lock` from inside the
`varset-regression-stack/` directory, **or** paste the content below directly (it locks
`hashicorp/random ~> 3.9.0` which is all this stack needs):

```hcl
# This file is maintained automatically by "terraform stacks providers-lock".
# Manual edits may be lost in future updates.

provider "registry.terraform.io/hashicorp/random" {
  version = "3.9.0"
  hashes = [
    "h1:OO+IuvQJSPmWdN8AyyIEvPJbLvDQpgX/zbktoa9KsJE=",
    "h1:UlBuNVuCGJ39tTv2c5gz2NRZnQbXfbIWbTzWcth5o74=",
    "h1:fPNScahhsTwCvQTHBwvie1+67qkRZxXgPMCcwm6Rq60=",
    "h1:lVDv+0AjDjrLfpmaJbWqUmIw/k3/AHXLc3N4m55SNdo=",
    "zh:161ad0bd9a75768c82f53fb6e7172a9d8be2d4889b012645a34795031aaf1bf1",
    "zh:19dc9a5b17729725ccfc4f45b0500af0ee5bc6b6b160c7adb8f2bf617d2c80ea",
    "zh:269eda8fe42daa7974d5a34d166c3ba9defe80cde86c01e4dadcfdf2e1f05e5f",
    "zh:373f7c65566f8f2cc7f45d698654feb9d988996957e1266a69ca00c52d6d16d0",
    "zh:5599d16804c41c83009ec621b6d6b6f74e102f5827678a4750f8809055546b61",
    "zh:583be0440469a22bff70dcfa56593b01566860b29607437264adb51060cf46fc",
    "zh:5f211d8ec3f2e1f414870d9584bfe26e6995560ef81c748f8447a48164767398",
    "zh:78d5eefdd9e494defcb3c68d282b8f96630502cac21d1ea161f53cfe9bb483b3",
    "zh:7b547fd16216761ef86efc3ed516ac5ac0c5c42b7c7eb24a08cef2d93f69ed5e",
    "zh:7e7c0679daf2a382151d05068c8c3f0dae6b7b7dccf818827b73dd08638df2ef",
    "zh:8089dec888a8038b9b4fb23b3df7e1057293dbc5b60b42cc47ff690d69d4b61b",
    "zh:c51f15a031edfd6f23ce8ced3446ca7f8d8d647e2499890d7d5d10d5016d7257",
    "zh:c94784f005708890dc6895afd53636ec00ec1e430b15d41e5aebfb1d4b39bd04",
  ]
}
```

---

### Step 3 — Push to your repository

```bash
cd varset-regression-stack
git init
git add .
git commit -m "Initial stack structure for varset regression testing"
git remote add origin https://github.com/<your-org>/varset-regression-stack.git
git push -u origin main
```

---

## Part 2 — Connect the repository to a Stack in HCP Terraform

1. In HCP Terraform, navigate to your project → **Stacks → + New stack**.
2. Name it `varset-regression-stack`.
3. Under **Source**, choose your VCS provider and select the `varset-regression-stack` repository.
4. Set the **Terraform version** to match your `.terraform-version` file (e.g. `1.15.5`).
5. Click **Create stack**.

The Stack will attempt its first configuration upload. It will fail to prepare because the
`store "varset" "my-varset"` block has no `name` or `id` set yet — that is expected. You
will fill that in at the start of each test case.

> **Manual upload alternative (no VCS):** If you are not using VCS, create the Stack with
> source type **manual**, then use the HCP Terraform API or UI to upload a `.tar.gz` of
> the directory before each test case run.

---

## Part 3 — How to trigger a run for each test case

Each test case asks you to "push the configuration" or "trigger a new Stack run". Here is
what that means in practice:

**If using VCS:**
1. Edit `main.tfcomponent.hcl` locally to update the `store "varset"` block for the test case.
2. Commit and push to `main`.
3. HCP Terraform detects the push and automatically creates a new Stack configuration.

**If using manual upload:**
1. Edit the file locally.
2. Create a new configuration via the UI (**New configuration** button on the Stack page), or use the API.
3. Upload the `.tar.gz` to the provided upload URL.

---

> **Note:** Update the `store "varset" "my-varset"` block in each test case with either
> the `id` (external ID, e.g. `varset-xxxxxxxxxxxx`) or `name` of the varset you create.

---

## Test Case 1 — Varset attached directly to a Stack; plan and apply succeed

### Setup

1. In the HCP Terraform UI, go to **Settings → Variable sets → + New variable set**.
2. Name it `tc1-stack-varset`.
3. Under **Variable set scope**, select **"Apply to specific projects, Stacks and workspaces"**.
4. Under **Apply to Stacks**, select your Stack.
5. Add the following variables to the varset:

   | Category  | Key           | Value       | Sensitive |
   |-----------|---------------|-------------|-----------|
   | Terraform | `region`      | `us-east-1` | No        |
   | Terraform | `environment` | `production`| No        |

6. Save the varset.
7. Update the `store "varset" "my-varset"` block in `main.tfcomponent.hcl` to reference this varset:

   ```hcl
   store "varset" "my-varset" {
     name = "tc1-stack-varset"
   }
   ```

8. Push the stack configuration (commit and push, or re-upload via the UI).

### Steps

1. In the HCP Terraform UI, navigate to your Stack.
2. Trigger a new run (or wait for the VCS-triggered configuration to appear).
3. Review the plan output under the **production** deployment.
4. Approve and apply the run.

### Expected behavior

- The plan completes successfully with no "unknown variable" or "missing required variable" errors.
- In the plan output, `region` resolves to `us-east-1` and `environment` resolves to `production`.
- The apply completes successfully.
- Both output values (`region_out`, `environment_out`) appear in the stack outputs with the correct values.

---

## Test Case 1b — Varset applied at the project scope; Stack inherits variables

This test confirms that a varset scoped to the **project** that contains the Stack is
automatically available to the Stack — no direct Stack assignment is required.

### Setup

1. In the HCP Terraform UI, go to **Settings → Variable sets → + New variable set**.
2. Name it `tc1b-project-varset`.
3. Under **Variable set scope**, select **"Apply to specific projects, Stacks and workspaces"**.
4. Under **Apply to projects**, select the project that contains your Stack. Do **not** add the Stack under "Apply to Stacks".
5. Add the following variables:

   | Category  | Key           | Value        | Sensitive |
   |-----------|---------------|--------------|-----------|
   | Terraform | `region`      | `eu-west-1`  | No        |
   | Terraform | `environment` | `project-env`| No        |

6. Save the varset.
7. Update the `store "varset" "my-varset"` block in `deployments.tfdeploy.hcl` to reference this varset:

   ```hcl
   store "varset" "my-varset" {
     name     = "tc1b-project-varset"
     category = "terraform"
   }
   ```

8. Push the stack configuration.

### Steps

1. In the HCP Terraform UI, navigate to your Stack.
2. Trigger a new run.
3. Review the plan output under the **production** deployment.
4. Approve and apply the run.

### Expected behavior

- The plan completes successfully with no "unknown variable" or "missing required variable" errors.
- `region` resolves to `eu-west-1` and `environment` resolves to `project-env` — sourced from the project-scoped varset, not a direct Stack assignment.
- The apply completes successfully.
- Both output values (`region_out`, `environment_out`) appear in the Stack outputs with the correct values.

---

## Test Case 1c — Varset applied globally to the organization; Stack inherits variables

This test confirms that a varset scoped to the **entire organization** is available to all
Stacks without any project- or Stack-level assignment.

### Setup

1. In the HCP Terraform UI, go to **Settings → Variable sets → + New variable set**.
2. Name it `tc1c-global-varset`.
3. Under **Variable set scope**, select **"Apply globally"** (applies to all projects, Stacks, and workspaces in the organization).
4. Add the following variables:

   | Category  | Key           | Value        | Sensitive |
   |-----------|---------------|--------------|-----------|
   | Terraform | `region`      | `ap-east-1`  | No        |
   | Terraform | `environment` | `global-env` | No        |

5. Save the varset.
6. Update the `store "varset" "my-varset"` block in `deployments.tfdeploy.hcl` to reference this varset:

   ```hcl
   store "varset" "my-varset" {
     name     = "tc1c-global-varset"
     category = "terraform"
   }
   ```

7. Push the stack configuration.

### Steps

1. In the HCP Terraform UI, navigate to your Stack.
2. Trigger a new run.
3. Review the plan output under the **production** deployment.
4. Approve and apply the run.

### Expected behavior

- The plan completes successfully with no "unknown variable" or "missing required variable" errors.
- `region` resolves to `ap-east-1` and `environment` resolves to `global-env` — sourced from the globally-scoped varset with no direct project or Stack assignment.
- The apply completes successfully.
- Both output values (`region_out`, `environment_out`) appear in the Stack outputs with the correct values.

> **Cleanup note:** Delete or set the scope of `tc1c-global-varset` back to a specific project
> after this test. A globally-scoped varset will interfere with later test cases that verify
> priority resolution and removal behavior.

---

## Test Case 2 — Two varsets defining the same key; priority flag resolves correctly

This test confirms that when two varsets both define the same key and one has **Priority** enabled,
the priority varset wins.

### Setup

1. Create a first varset named `tc2-base-varset`:
   - Scope: assigned directly to your Stack
   - Variable: `region` = `us-west-2` (Terraform category)
   - Priority: **off**

2. Create a second varset named `tc2-priority-varset`:
   - Scope: assigned directly to your Stack
   - Variable: `region` = `eu-central-1` (Terraform category)
   - Priority: **on** (check "Prioritize the variables in this set")

3. Update `main.tfcomponent.hcl` to only reference the `region` key (remove `environment` for simplicity):

   ```hcl
   component "app" {
     source = "./modules/app"

     inputs = {
       region = store.varset.my-varset.region
     }
   }

   store "varset" "my-varset" {
     name = "tc2-base-varset"
   }
   ```

   > The stack references `tc2-base-varset` explicitly. Both varsets are assigned to the stack,
   > so both are available. The priority flag determines which value wins when the same key exists
   > across multiple varsets.

4. Push the configuration.

### Steps

**Part A — Confirm base varset value without priority:**

1. Temporarily disable the **Priority** flag on `tc2-priority-varset` (edit the varset and uncheck priority).
2. Trigger a new Stack run.
3. Check the plan output for the `region` value.

**Part B — Enable priority and confirm override:**

4. Edit `tc2-priority-varset` and re-enable the **Priority** flag.
5. Trigger another Stack run.
6. Check the plan output for the `region` value.

### Expected behavior

- **Part A:** `region` resolves to `us-west-2` (from `tc2-base-varset`, the non-priority varset).
- **Part B:** `region` resolves to `eu-central-1` (from `tc2-priority-varset`, the priority varset overrides the base varset regardless of scope specificity).
- No plan errors in either part.

---

## Test Case 3 — Update a varset value; next Stack run picks up the new value

This test confirms there is no stale caching — a value change in a varset is reflected on
the very next run without needing to modify the stack configuration.

### Setup

1. Create a varset named `tc3-update-varset`:
   - Scope: assigned directly to your Stack
   - Variable: `region` = `us-east-1` (Terraform category)

2. Update `main.tfcomponent.hcl` to reference it:

   ```hcl
   component "app" {
     source = "./modules/app"

     inputs = {
       region = store.varset.my-varset.region
     }
   }

   store "varset" "my-varset" {
     name = "tc3-update-varset"
   }
   ```

3. Push and run the Stack until a successful apply. Confirm `region_out` = `us-east-1` in the outputs.

### Steps

1. In the UI, navigate to **Settings → Variable sets** and open `tc3-update-varset`.
2. Click **Edit variable set**.
3. Change the value of `region` from `us-east-1` to `ap-southeast-1`.
4. Click **Save variable set**. Do **not** push any new stack configuration code.
5. Trigger a new Stack run (via the UI **New run** button, or wait for a VCS trigger if applicable).
6. Inspect the plan output for the `production` deployment.

### Expected behavior

- The plan shows `region` = `ap-southeast-1` (the updated value).
- The plan does **not** show `us-east-1` (the old value is not cached).
- No configuration upload or code change was needed to pick up the new value.
- The apply completes successfully with the updated value in outputs.

---

## Test Case 4 — Remove varset from a Stack; variable disappears from subsequent runs

This test confirms that once a varset is unassigned from a Stack, the next run can no longer
resolve the variables it provided.

### Setup

1. Create a varset named `tc4-removal-varset`:
   - Scope: assigned directly to your Stack
   - Variable: `region` = `us-east-1` (Terraform category)

2. Update `main.tfcomponent.hcl`:

   ```hcl
   component "app" {
     source = "./modules/app"

     inputs = {
       region = store.varset.my-varset.region
     }
   }

   store "varset" "my-varset" {
     name = "tc4-removal-varset"
   }
   ```

3. Push and confirm a successful plan/apply with `region` = `us-east-1`.

### Steps

1. In the UI, navigate to **Settings → Variable sets** and open `tc4-removal-varset`.
2. Click **Edit variable set**.
3. Under **Apply to Stacks**, remove your Stack from the selection (click the × on the Stack chip).
4. Click **Save variable set**.
5. Trigger a new Stack run without making any code changes.
6. Observe the plan output.

### Expected behavior

- The run fails at the plan step.
- The error message references the missing varset or unresolvable store — something along the lines of `Referenced variable set tc4-removal-varset doesn't exist, or isn't assigned to this stack's project.`
- The error is surfaced as a diagnostic on the deployment, not a silent hang or an unrelated internal error.
- No apply is attempted.

---

## Test Case 5 — Delete a varset entirely; Stack run fails gracefully with a clear error

This test verifies that when a varset referenced by a Stack's configuration is deleted,
the resulting run failure is a user-understandable diagnostic — not an unrelated 500-level error
or a silent pass with empty variables.

### Setup

1. Create a varset named `tc5-delete-varset`:
   - Scope: assigned directly to your Stack
   - Variable: `region` = `us-east-1` (Terraform category)

2. Update `main.tfcomponent.hcl`:

   ```hcl
   component "app" {
     source = "./modules/app"

     inputs = {
       region = store.varset.my-varset.region
     }
   }

   store "varset" "my-varset" {
     name = "tc5-delete-varset"
   }
   ```

3. Push and confirm a successful plan/apply.

### Steps

1. In the UI, navigate to **Settings → Variable sets** and open `tc5-delete-varset`.
2. Click **Edit variable set**.
3. Click **Delete variable set**.
4. In the confirmation modal, type the varset name and confirm.
5. Trigger a new Stack run (do not push new configuration — the stack config still references the deleted varset by name).
6. Observe the run status and error message.

### Expected behavior

- The run fails — it does not silently pass with empty or zero-value variables.
- The failure message is human-readable and specifically mentions the missing variable set, e.g.: `Referenced variable set tc5-delete-varset doesn't exist, or isn't assigned to this stack's project.`
- The error is shown as a diagnostic attached to the affected deployment, visible in the Stack run UI.
- No apply is attempted.
- The Stack itself (and other runs not referencing this varset) is unaffected.

---

## Test Case 6 — Varset applied to a Stack with multiple deployments; correct deployments inherit variables

This test confirms that when a varset is applied to a Stack that has multiple deployments,
only the deployments whose `store` blocks reference the varset receive its variables.
Deployments that do not reference the varset are unaffected.

### Setup

Update `deployments.tfdeploy.hcl` to define two deployments:

```hcl
deployment "production" {
  inputs = {}
}

deployment "staging" {
  inputs = {}
}
```

Update `main.tfcomponent.hcl` so only the `production` deployment's component references the varset.
The `staging` component uses a hardcoded fallback instead:

```hcl
component "app_production" {
  source = "./modules/app"

  inputs = {
    region      = store.varset.my-varset.region
    environment = store.varset.my-varset.environment
  }
}

component "app_staging" {
  source = "./modules/app"

  inputs = {
    region      = "us-west-1"   # hardcoded — does not use the varset
    environment = "staging"
  }
}

store "varset" "my-varset" {
  name = "tc6-scoped-varset"
}
```

Create a varset named `tc6-scoped-varset`:
- Scope: assigned directly to your Stack
- Variables:

  | Category  | Key           | Value        | Sensitive |
  |-----------|---------------|--------------|-----------|
  | Terraform | `region`      | `us-east-1`  | No        |
  | Terraform | `environment` | `production` | No        |

Push the configuration.

### Steps

1. Trigger a new Stack run.
2. Wait for the plan to complete across both the `production` and `staging` deployments.
3. Inspect the plan output for the **production** deployment.
4. Inspect the plan output for the **staging** deployment.

### Expected behavior

- **production deployment:**
  - `region` = `us-east-1` (from `tc6-scoped-varset`)
  - `environment` = `production` (from `tc6-scoped-varset`)
  - Plan completes successfully.

- **staging deployment:**
  - `region` = `us-west-1` (hardcoded — varset not referenced)
  - `environment` = `staging` (hardcoded — varset not referenced)
  - Plan completes successfully with no mention of `tc6-scoped-varset`.

- Neither deployment errors.
- The varset variables do **not** bleed into the staging deployment simply because the varset is assigned to the Stack.

---

## Notes for future test cases

- Each test case is self-contained. Re-use the same Stack and repository but create fresh varsets per test to avoid state bleed between cases.
- After finishing each test, clean up by deleting the varset created for that test and resetting the stack configuration to a neutral state.
- If extending this document with new test cases, follow the same structure: **Setup → Steps → Expected behavior**.
