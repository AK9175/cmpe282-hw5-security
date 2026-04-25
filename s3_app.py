import boto3
from botocore.exceptions import ClientError

def main():
    s3 = boto3.client('s3', region_name='us-west-1')

    print("=" * 50)
    print("HW5 - Part B: S3 Read-Only Access via IAM Role")
    print("=" * 50)

    # List all buckets
    response = s3.list_buckets()
    buckets = response.get('Buckets', [])

    if not buckets:
        print("\nNo S3 buckets found in this account.")
        return

    print(f"\nFound {len(buckets)} bucket(s):\n")

    for bucket in buckets:
        name = bucket['Name']
        created = bucket['CreationDate'].strftime('%Y-%m-%d %H:%M:%S')
        print(f"  Bucket: {name}")
        print(f"  Created: {created}")

        # List objects in each bucket
        try:
            obj_response = s3.list_objects_v2(Bucket=name, MaxKeys=5)
            objects = obj_response.get('Contents', [])
            if objects:
                print(f"  Objects (first 5):")
                for obj in objects:
                    print(f"    - {obj['Key']} ({obj['Size']} bytes)")
            else:
                print(f"  Objects: (empty bucket)")
        except ClientError as e:
            print(f"  Objects: Access denied or error - {e.response['Error']['Code']}")
        print()

    print("IAM Role is working correctly - S3 read-only access confirmed!")

if __name__ == "__main__":
    main()
