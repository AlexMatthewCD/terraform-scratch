import boto3

region = 'ap-south-1'
ec2_resource = boto3.resource('ec2', region_name=region)
ec2_client = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    action = event.get('action')

    target_instances = []
    
    for instance in ec2_resource.instances.all():
        if instance.tags:
            for tag in instance.tags:
                if tag['Key'] == 'AutomaticSchedule' and tag['Value'] == 'Enabled':
                    target_instances.append(instance.id)
                    break

    if not target_instances:
        return

    if action == 'start':
        ec2_client.start_instances(InstanceIds=target_instances)
        print("Instance started")
    elif action == 'stop':
        ec2_client.stop_instances(InstanceIds=target_instances)
        print("Instance stopped")