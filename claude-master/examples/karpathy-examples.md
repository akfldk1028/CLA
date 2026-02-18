# Karpathy 4 principles - code examples

## 1. Think before coding

**Bad** - assumes without asking:
```
User: "Add validation"
Claude: *immediately writes email regex, phone parser, and 200 lines of validation*
```

**Good** - surfaces assumptions:
```
User: "Add validation"
Claude: "Before I implement, a few questions:
- What fields need validation? (email, phone, all form fields?)
- What validation library is already in use, if any?
- Should invalid input show inline errors or a summary?"
```

## 2. Simplicity first

**Bad** - over-engineered:
```python
class ValidatorFactory:
    _registry = {}
    @classmethod
    def register(cls, name):
        def decorator(validator_cls):
            cls._registry[name] = validator_cls
            return validator_cls
        return decorator
    @classmethod
    def create(cls, name, **kwargs):
        return cls._registry[name](**kwargs)
```

**Good** - minimum viable:
```python
def validate_email(email: str) -> bool:
    return "@" in email and "." in email.split("@")[1]
```

## 3. Surgical changes

**Bad** - drive-by refactoring:
```diff
- def get_user(id):
-     # get user from db
-     user = db.query(f"SELECT * FROM users WHERE id = {id}")
-     return user
+ def get_user(user_id: int) -> Optional[User]:
+     """Fetch a user by their unique identifier."""
+     user = db.query(User).filter(User.id == user_id).first()
+     if not user:
+         raise UserNotFoundError(f"User {user_id} not found")
+     return user
```

**Good** - only the requested change (fix SQL injection):
```diff
  def get_user(id):
-     user = db.query(f"SELECT * FROM users WHERE id = {id}")
+     user = db.query("SELECT * FROM users WHERE id = %s", (id,))
      return user
```

## 4. Goal-driven execution

**Bad** - vague approach:
```
Task: "Fix the login bug"
Claude: *reads code, makes changes, says "I think this should fix it"*
```

**Good** - verifiable goals:
```
Task: "Fix the login bug"
Plan:
1. Write failing test that reproduces the bug -> verify: test fails
2. Fix the root cause -> verify: test passes
3. Run full test suite -> verify: no regressions
```
