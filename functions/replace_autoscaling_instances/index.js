const AWS = require('aws-sdk');

// AWS.config.region = process.env.AWS_DEFAULT_REGION;

const AutoScaling = new AWS.AutoScaling();

exports.handle = (event, ctx, cb) => {
  console.log('processing event: %j', event);

  const message = JSON.parse(event.Records[0].Sns.Message);
  console.log('ASG name:', message.asgName);

  AutoScaling.describeAutoScalingGroups({
    AutoScalingGroupNames: [message.asgName],
  }).promise()
    .then(data => data.AutoScalingGroups[0])
    .then(validateAsgCapacity)
    .then(multipleDesiredCapacity)
    .then(() => cb(null, {message: 'success'}))
  ;
};

function validateAsgCapacity(asg) {
  if (!asg) {
    throw 'The autoscaling group name does not exist...';
  }
  if (asg.DesiredCapacity * 2 > asg.MaxSize) {
    throw 'Max capacity is too small so that it can not replace instances.';
  }
  console.log(`Current desired capacity is ${asg.DesiredCapacity}`);

  return asg;
}

function multipleDesiredCapacity(asg) {
  console.log(`Scale out to ${asg.DesiredCapacity * 2}.`);

  return AutoScaling.setDesiredCapacity({
    AutoScalingGroupName: asg.AutoScalingGroupName,
    DesiredCapacity: asg.DesiredCapacity * 2,
    HonorCooldown: true,
  }).promise();
}

