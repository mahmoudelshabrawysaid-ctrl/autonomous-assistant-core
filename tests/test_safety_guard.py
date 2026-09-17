import unittest

from assistant.safety_guard import Scope, validate


class SafetyGuardTests(unittest.TestCase):
    def test_accepts_authorized_scoped_action(self):
        ok, message = validate(Scope("127.0.0.1", True, "scan"))
        self.assertTrue(ok)
        self.assertEqual(message, "Scope accepted.")

    def test_rejects_empty_target(self):
        ok, _ = validate(Scope("", True, "scan"))
        self.assertFalse(ok)

    def test_rejects_missing_authorization(self):
        ok, _ = validate(Scope("127.0.0.1", False, "scan"))
        self.assertFalse(ok)

    def test_rejects_empty_action(self):
        ok, _ = validate(Scope("127.0.0.1", True, ""))
        self.assertFalse(ok)


if __name__ == "__main__":
    unittest.main()
