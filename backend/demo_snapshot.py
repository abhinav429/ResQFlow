"""Default scenario snapshot for the digital twin when no browser session exists."""

from __future__ import annotations

RESOURCE_TYPES = [
    {"type": "Ambulance", "capabilities": ["medical", "evacuation"], "capacity": 2},
    {"type": "Rescue Boat", "capabilities": ["flood", "evacuation"], "capacity": 6},
    {"type": "Drone", "capabilities": ["survey", "medical"], "capacity": 1},
    {"type": "Food Truck", "capabilities": ["food", "shelter"], "capacity": 12},
    {"type": "Medical Team", "capabilities": ["medical", "shelter"], "capacity": 4},
    {"type": "Volunteer Team", "capabilities": ["food", "evacuation", "shelter"], "capacity": 8},
]

INCIDENT_SEEDS = [
    {"type": "Flood Rescue", "need": "flood", "urgency": 95, "people": 5, "x": 21, "y": 15},
    {"type": "Medical Emergency", "need": "medical", "urgency": 90, "people": 2, "x": 38, "y": 29},
    {"type": "Food Delivery", "need": "food", "urgency": 62, "people": 18, "x": 18, "y": 38},
    {"type": "Shelter Overflow", "need": "shelter", "urgency": 72, "people": 25, "x": 31, "y": 10},
    {"type": "Evacuation Help", "need": "evacuation", "urgency": 84, "people": 8, "x": 12, "y": 27},
]

RESOURCE_PLACEMENTS = [
    {"x": 5, "y": 5},
    {"x": 7, "y": 8},
    {"x": 45, "y": 7},
    {"x": 43, "y": 43},
    {"x": 8, "y": 44},
    {"x": 11, "y": 41},
    {"x": 46, "y": 11},
    {"x": 4, "y": 39},
]


def build_demo_snapshot() -> dict:
    resources = []
    for index, pos in enumerate(RESOURCE_PLACEMENTS):
        definition = RESOURCE_TYPES[index % len(RESOURCE_TYPES)]
        resources.append(
            {
                "id": index + 1,
                "type": definition["type"],
                "x": pos["x"],
                "y": pos["y"],
                "fuel": 85,
                "status": "available",
                "capabilities": definition["capabilities"],
                "capacity": definition["capacity"],
                "assignedIncidentId": None,
                "completed": 0,
            }
        )

    incidents = []
    for index, seed in enumerate(INCIDENT_SEEDS):
        incidents.append(
            {
                "id": index + 1,
                "type": seed["type"],
                "need": seed["need"],
                "urgency": seed["urgency"],
                "people": seed["people"],
                "x": seed["x"],
                "y": seed["y"],
                "status": "pending",
                "assignedResourceId": None,
                "sourceText": "",
            }
        )

    return {
        "strategy": "balanced",
        "resolved": 0,
        "repairCount": 0,
        "decisions": 0,
        "totalScore": 0,
        "bases": [
            {"x": 5, "y": 5, "label": "North Base"},
            {"x": 45, "y": 7, "label": "Medical Depot"},
            {"x": 8, "y": 44, "label": "Relief Hub"},
            {"x": 43, "y": 43, "label": "Rescue Camp"},
        ],
        "riskZones": [
            {"x": 25, "y": 18, "r": 6, "level": 72, "label": "Flooded road"},
            {"x": 35, "y": 32, "r": 5, "level": 64, "label": "Debris zone"},
            {"x": 15, "y": 29, "r": 4, "level": 58, "label": "Congestion"},
        ],
        "resources": resources,
        "incidents": incidents,
        "latestTrace": None,
        "recentTraces": [],
    }
