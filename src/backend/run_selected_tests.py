import unittest

test_modules = [
    'openapi_server.test.test_benutzer_controller',
]

loader = unittest.TestLoader()
suites = [loader.loadTestsFromName(mod) for mod in test_modules]

combined_suite = unittest.TestSuite(suites)

runner = unittest.TextTestRunner(verbosity=2)
runner.run(combined_suite)