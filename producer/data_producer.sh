
if [ $# -eq 0 ]
  then
    echo "input for tag for the demo needed !!!"
    exit 1
fi

echo "starting device metrics generator"
python3 producer.py -k $1 -r $AWS_DEFAULT_REGION -t 200
exit
