import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.preprocessing import StandardScaler
import mlflow
import mlflow.sklearn
import joblib
import os

# MLflow tracking
mlflow.set_tracking_uri(os.getenv("MLFLOW_TRACKING_URI", "http://localhost:5000"))
mlflow.set_experiment("house-price-prediction")

def generate_data(n=1000):
    np.random.seed(42)
    data = pd.DataFrame({
        "area":         np.random.randint(500, 5000, n),
        "bedrooms":     np.random.randint(1, 6, n),
        "bathrooms":    np.random.randint(1, 4, n),
        "age":          np.random.randint(0, 50, n),
        "distance_km":  np.random.uniform(1, 50, n),
        "floor":        np.random.randint(1, 20, n),
    })
    data["price"] = (
        data["area"] * 150 +
        data["bedrooms"] * 50000 +
        data["bathrooms"] * 30000 -
        data["age"] * 2000 -
        data["distance_km"] * 5000 +
        data["floor"] * 10000 +
        np.random.normal(0, 20000, n)
    )
    return data

def train():
    print("Loading data...")
    df = generate_data()

    X = df.drop("price", axis=1)
    y = df["price"]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    scaler = StandardScaler()
    X_train = scaler.fit_transform(X_train)
    X_test  = scaler.transform(X_test)

    with mlflow.start_run():
        # Hyperparameters
        n_estimators = 100
        max_depth    = 10

        mlflow.log_param("n_estimators", n_estimators)
        mlflow.log_param("max_depth",    max_depth)
        mlflow.log_param("test_size",    0.2)

        # Train model
        print("Training model...")
        model = RandomForestRegressor(
            n_estimators=n_estimators,
            max_depth=max_depth,
            random_state=42
        )
        model.fit(X_train, y_train)

        # Evaluate
        preds = model.predict(X_test)
        rmse  = np.sqrt(mean_squared_error(y_test, preds))
        r2    = r2_score(y_test, preds)

        mlflow.log_metric("rmse", rmse)
        mlflow.log_metric("r2_score", r2)

        print(f"RMSE:     {rmse:.2f}")
        print(f"R2 Score: {r2:.4f}")

        # Save model + scaler
        os.makedirs("model/artifacts", exist_ok=True)
        joblib.dump(model,  "model/artifacts/model.pkl")
        joblib.dump(scaler, "model/artifacts/scaler.pkl")

        mlflow.sklearn.log_model(model, "house-price-model")
        print("Model saved successfully!")

if __name__ == "__main__":
    train()
