import argparse
import json
import os
import sys
import anthropic


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--logs", required=True)
    parser.add_argument("--pod-status", required=True)
    parser.add_argument("--health-response", required=True)
    args = parser.parse_args()

    client = anthropic.Anthropic(api_key=os.environ.get("ANTHROPIC_API_KEY"))

    message = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=1000,
        system="You are a DevOps reliability engineer. Respond ONLY with valid JSON.",
        messages=[{
            "role": "user",
            "content": f"""Analyze this Kubernetes deployment and determine if it is healthy.

Pod Status:
{args.pod_status[:3000]}

Recent Logs:
{args.logs[:3000]}

Health Endpoint Response:
{args.health_response}

Return JSON with keys:
- verdict: HEALTHY, DEGRADED, or UNHEALTHY
- confidence: float 0.0 to 1.0
- summary: 2-3 sentence plain English explanation
- issues: list of specific problems found
- recommendation: KEEP, MONITOR, or ROLLBACK"""
        }]
    )

    try:
        result = json.loads(message.content[0].text)
    except json.JSONDecodeError:
        print("Could not parse AI response as JSON")
        sys.exit(0)

    print(f"\nVerdict: {result.get('verdict')}")
    print(f"Confidence: {result.get('confidence', 0) * 100:.0f}%")
    print(f"Summary: {result.get('summary')}")

    issues = result.get("issues", [])
    if issues:
        print("\nIssues found:")
        for issue in issues:
            print(f"  - {issue}")

    with open("ai_health_report.json", "w") as f:
        json.dump(result, f, indent=2)

    verdict = result.get("verdict", "HEALTHY")
    if verdict == "UNHEALTHY":
        print("\nDeployment is UNHEALTHY — triggering rollback")
        sys.exit(1)
    elif verdict == "DEGRADED":
        print("\nDeployment is DEGRADED — monitoring recommended")
        sys.exit(2)
    else:
        print("\nDeployment is HEALTHY")
        sys.exit(0)


if __name__ == "__main__":
    main()