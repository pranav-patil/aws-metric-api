'use strict';

async function callDescribeStream(kinesis, kinesisStreamName) {
    var streamArn = null;
    try {
        const { StreamDescription } = await kinesis.describeStream({ StreamName: kinesisStreamName }).promise();
        streamArn = StreamDescription.StreamARN;
        if (!streamArn) {
            console.log("Failed to get ARN for Kinesis stream " + kinesisStreamName);
        }
    } catch(err) {
        console.log(err.message);
    }
    return streamArn;
}

module.exports.getStreamArn = async ({ resolveVariable }) => {
    const AWS = require("aws-sdk");
    const region = await resolveVariable('opt:region, self:provider.region, "us-west-1"');
    const kinesis = new AWS.Kinesis({ region });
    var kinesisStreamName = await resolveVariable('self:custom.kinesisStream.name');
    return await callDescribeStream(kinesis, kinesisStreamName);
};

