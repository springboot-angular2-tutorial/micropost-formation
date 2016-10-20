const AWS = require('aws-sdk');
const ArgumentParser = require('argparse').ArgumentParser;

AWS.config.region = process.env.AWS_DEFAULT_REGION;

const AutoScaling = new AWS.AutoScaling();

function parseArguments() {
  const parser = new ArgumentParser({
    description: 'This script scale out specified auto scaling group to flip out old instances.',
  });
  parser.addArgument(['-n', '--name'], {
    help: 'name of a auto scaling group',
    required: true,
  });
  return parser.parseArgs();
}

function validateAsgCapacity(asg) {
  if (!asg) {
    console.error('This autoscaling group does not exist...');
    process.exit(1);
  }
  if (asg.DesiredCapacity * 2 > asg.MaxSize) {
    console.error(`Can not scale out to replace instances. Consider increasing the max capacity.`);
    process.exit(1);
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

const asgName = parseArguments().name;

AutoScaling.describeAutoScalingGroups({
  AutoScalingGroupNames: [asgName],
}).promise()
  .then(data => data.AutoScalingGroups[0])
  .then(validateAsgCapacity)
  .then(multipleDesiredCapacity);
