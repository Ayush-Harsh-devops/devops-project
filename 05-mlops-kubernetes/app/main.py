from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib
import numpy as np
import os
from prometheus_client import Counter, Histogram, generate_latest
from starlette.responses import Response

app = FastAPI(title="House Price Prediction API", version="1.0.0")

# Prometheus metrics
REQUEST_COUNT = Counter('prediction_requests_total', 'Total prediction requests')
REQUEST_LATENCY = Histogram('prediction_latency_seconds', 'Prediction latency')

# Load model
model  = joblib.load("model/artifacts/model.pkl")
scaler = joblib.load("model/artifacts/scaler.pkl")

class HouseFeatures(BaseModel):
    area: float
    bedrooms: int
    bathrooms: int
    age: int
    distance_km: float
    floor: int

class PredictionResponse(BaseModel):
    predicted_price: float
    currency: str = "INR"

@app.get("/health")
def health():
    return {"status": "healthy", "model": "house-price-v1"}

@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type="text/plain")

@app.post("/predict", response_model=PredictionResponse)
def predict(features: HouseFeatures):
    REQUEST_COUNT.inc()
    with REQUEST_LATENCY.time():
        try:
            data = np.array([[
                features.area,
                features.bedrooms,
                features.bathrooms,
                features.age,
                features.distance_km,
                features.floor
            ]])
            scaled = scaler.transform(data)
            price  = model.predict(scaled)[0]
            return PredictionResponse(predicted_price=round(price, 2))
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
