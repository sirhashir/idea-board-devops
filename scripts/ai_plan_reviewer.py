import argparse
import json
import os
import sys
import anthropic


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--plan-output", required=True)
    args = parser.parse_args()

    client = anthropic.Anthropic(api_key=os.environ.get("ANTHROPIC_API_KEY"))

    message = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=1000,
        system="You are a cloud security expert. Respond ONLY with valid JSON.",
        messages=[{
            "role": "user",
            "content": f"""Review this Terraform plan for security issues, 
misconfigurations, and unexpected costs.

Terraform Plan:
{args.plan_output[:4000]}

Return JSON with keys:
- severity: PASS, WARN, or CRITICAL
- issues: list of objects with keys: severity, description, resource
- cost_notes: string about estimated costs
- security_score: integer 0-10
- summary: brief overall assessment"""
        }]
    )

    try:
        result = json.loads(message.content[0].text)
    except json.JSONDecodeError:
        print("Could not parse AI response — proceeding")
        sys.exit(0)

    print(f"\nSeverity: {result.get('severity')}")
    print(f"Security Score: {result.get('security_score')}/10")
    print(f"Summary: {result.get('summary')}")
    print(f"Cost Notes: {result.get('cost_notes')}")

    issues = result.get("issues", [])
    if issues:
        print("\nIssues found:")
        for issue in issues:
            print(f"  [{issue.get('severity')}] {issue.get('description')}")

    with open("ai_plan_review.json", "w") as f:
        json.dump(result, f, indent=2)

    severity = result.get("severity", "PASS")
    if severity == "CRITICAL":
        print("\nCRITICAL issues found — blocking deployment")
        sys.exit(2)
    elif severity == "WARN":
        print("\nWarnings found — proceeding with caution")
        sys.exit(0)
    else:
        print("\nPlan looks good")
        sys.exit(0)


if __name__ == "__main__":
    main()