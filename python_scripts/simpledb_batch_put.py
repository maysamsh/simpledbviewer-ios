"""
Batch PUT 100 items into AWS SimpleDB domain 'maysoft' in us-east-1.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 SETUP: Python Virtual Environment (venv)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 1. Create the venv (one-time):
       python -m venv venv

 2. Activate it:
       macOS / Linux:   source venv/bin/activate
       Windows CMD:     venv\Scripts\activate.bat
       Windows PS:      venv\Scripts\Activate.ps1

    Your prompt will change to show (venv) when active.

 3. Install dependencies:
       pip install boto3

 4. Run the script:
       python simpledb_batch_put.py

 5. Deactivate when done (optional):
       deactivate

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AWS Credentials — one of:
   - Environment variables: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
   - ~/.aws/credentials  (created by: aws configure)
   - IAM role (if running on EC2 / Lambda)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"""

import boto3
import random
import string
import uuid

# ── Config ────────────────────────────────────────────────────────────────────
REGION      = "us-east-1"
DOMAIN_NAME = "maysoft"
TOTAL_ITEMS = 100
BATCH_SIZE  = 25          # SimpleDB BatchPutAttributes max per call

# ── Helpers ───────────────────────────────────────────────────────────────────
ALL_ATTR_NAMES = ["name", "apt number", "category", "date"]

def random_text(min_len: int = 4, max_len: int = 16) -> str:
    """Return a random alphanumeric string."""
    length = random.randint(min_len, max_len)
    return "".join(random.choices(string.ascii_letters + string.digits, k=length))

def random_date() -> str:
    """Return a random date string YYYY-MM-DD."""
    year  = random.randint(2000, 2025)
    month = random.randint(1, 12)
    day   = random.randint(1, 28)
    return f"{year}-{month:02d}-{day:02d}"

def make_value(attr_name: str) -> str:
    if attr_name == "date":
        return random_date()
    if attr_name == "apt number":
        return str(random.randint(1, 999))
    return random_text()

def build_item(item_index: int) -> dict:
    """Build one SimpleDB item with 1–4 random attributes."""
    chosen_attrs = random.sample(ALL_ATTR_NAMES, k=random.randint(1, len(ALL_ATTR_NAMES)))
    attributes = [
        {"Name": attr, "Value": make_value(attr), "Replace": True}
        for attr in chosen_attrs
    ]
    return {
        "Name": f"item-{item_index:04d}-{uuid.uuid4().hex[:6]}",
        "Attributes": attributes,
    }

def chunks(lst: list, size: int):
    """Yield successive chunks of `size` from `lst`."""
    for i in range(0, len(lst), size):
        yield lst[i : i + size]

# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    client = boto3.client("sdb", region_name=REGION)

    # 1. Build all 100 items
    items = [build_item(i) for i in range(1, TOTAL_ITEMS + 1)]

    # 2. Send in batches of 25 (SimpleDB hard limit)
    total_sent = 0
    for batch_num, batch in enumerate(chunks(items, BATCH_SIZE), start=1):
        response = client.batch_put_attributes(
            DomainName=DOMAIN_NAME,
            Items=batch,
        )
        http_status = response["ResponseMetadata"]["HTTPStatusCode"]
        total_sent += len(batch)
        print(f"  Batch {batch_num:2d}: sent {len(batch):2d} items "
              f"(total {total_sent}/{TOTAL_ITEMS}) — HTTP {http_status}")

    print(f"\nDone. {total_sent} items written to SimpleDB domain '{DOMAIN_NAME}'.")

    # 3. Quick sanity-check: count items in the domain
    meta = client.domain_metadata(DomainName=DOMAIN_NAME)
    print(f"Domain item count (may lag slightly): "
          f"{meta.get('ItemCount', 'n/a')}")

if __name__ == "__main__":
    main()
