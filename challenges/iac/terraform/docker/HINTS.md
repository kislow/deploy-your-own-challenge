# HINTS – Terraform Playground

------------------------------------

## Hint 1 – Do NOT create resources in the root

Your root Terraform files should NOT contain:

```hcl
resource "..."
````

The root module should only contain:

* module blocks
* variables
* outputs

If you see resources in `main.tf`, stop and fix this first.

---

## Hint 2 – One module, many resources

You should NOT copy and paste modules.

Instead:

* define your data in variables
* use `for_each` on the module

If you want 2 databases, your code should still have:

* ONE database module
* ONE module block

---

## Hint 3 – Think in maps, not numbers

Avoid `count`.

Use a map like this:

```hcl
databases = {
  users  = { ... }
  orders = { ... }
}
```

Then use `for_each = var.databases`.

---

## Hint 4 – Terraform connects things for you

Do NOT write database connection strings by hand.

Your app must get its database connection from:

* a Terraform output
* passed into the app module as a variable

If you hardcode a string, the task is not complete.

---

## Hint 5 – Terraform does not test connectivity

Terraform makes sure things are **wired correctly**.
It does NOT check if the app can talk to the database.

You test this by:

* using `psql`
* checking environment variables
* running `docker ps`

---

## Hint 6 – Small changes should be easy

If you need to change Terraform code
to add a third app or database,
something is wrong.

You should only need to change variables.

---

### 🧠 Note (for you)

> “If changing the number of resources requires changing Terraform code, you didn’t design it properly.”

## Checklist

1. Verify containers:
   docker ps

You should see:

2× postgres

2× app containers (nginx)

2. Connect to users DB:
    docker exec -it users psql -U user users

3. Verify app env vars:
   docker exec -it app1 env | grep DATABASE_URL

OUTPUT: $ DATABASE_URL=postgresql://user:password@localhost:5433/users

4. Destroy infra:
   terraform destroy

## Diagram

```mermaid
flowchart LR
    subgraph Host["Local Machine"]
        TF[Terraform]
        PS[psql / docker exec]
    end

    subgraph Docker["Docker Runtime"]
        APP[App Container]
        DB[(PostgreSQL Container)]
    end

    TF -->|provisions| APP
    TF -->|provisions| DB

    APP -->|DATABASE_URL| DB
    PS -->|connects via localhost port| DB
```
