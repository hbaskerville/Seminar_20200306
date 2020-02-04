while ($true) {
	echo "-------------------------"
	aws2 ec2 describe-instances --filters "Name=tag-value,Values=TFtest" --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State}" --output yaml
	
}