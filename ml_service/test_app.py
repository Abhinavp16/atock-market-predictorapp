import unittest

from app import engine


class MarketEngineTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        engine.train_model(["INFY", "TCS", "RELIANCE"])

    def test_health_has_model_metadata_shape(self) -> None:
        health = engine.health()
        self.assertEqual(health["status"], "ok")
        self.assertIn("modelVersion", health)

    def test_prediction_contains_provenance_fields(self) -> None:
        prediction = engine.predict("INFY")
        self.assertIn("modelVersion", prediction)
        self.assertIn("metrics", prediction)
        self.assertIn("explanation", prediction)
        self.assertIn("source", prediction)


if __name__ == "__main__":
    unittest.main()
