'use strict';

async function callDescribeKey(kms, keyId) {
    var keyArn = null;
    try {
        const { KeyMetadata } = await kms.describeKey({ KeyId: keyId }).promise();
        keyArn = KeyMetadata.Arn;
        if (!keyArn) {
            console.log("Failed to get ARN for KMS Key " + keyId);
        }
    } catch(err) {
        console.log(err.message);
    }
    return keyArn;
}

module.exports.getKmsKeyArn = async ({ resolveVariable }) => {
    const AWS = require("aws-sdk");
    const region = await resolveVariable('opt:region, self:provider.region, "us-west-1"');
    const kms = new AWS.KMS({ region });
    return await callDescribeKey(kms, "alias/KMS-emprovise-app");
};
