const AWS = require('aws-sdk');
const _ = require('lodash');

AWS.config.region = process.env.AWS_DEFAULT_REGION;

const EC2 = new AWS.EC2();
const AutoScaling = new AWS.AutoScaling();

function rotatedImages() {
  return EC2.describeImages({
    Filters: [
      {
        Name: 'tag:Rotated',
        Values: ['true'],
      },
    ],
  }).promise()
    .then(data => data.Images);
}

function unusedImageIds() {
  return AutoScaling.describeLaunchConfigurations({}).promise()
    .then(data => {
      return data.LaunchConfigurations.map(lc => lc.ImageId);
    });
}

function deregisterImage(image) {
  return EC2.deregisterImage({
    ImageId: image.ImageId,
  }).promise()
    .then(() => {
      console.log(`deregistered ${image.ImageId}`);
      return image;
    })
    // ignore error and continue
    .catch(() => image)
}

function deleteSnapShot(image) {
  const snapShotId = _.chain(image.BlockDeviceMappings)
    .flatten()
    .map(m => m.Ebs)
    .compact()
    .map(m => m.SnapshotId)
    .first()
    .value();
  return EC2.deleteSnapshot({
    SnapshotId: snapShotId,
  }).promise()
    .then(() => {
      console.log(`deleted ${snapShotId}`);
      return image;
    })
    .catch(() => image)
}

Promise.all([rotatedImages(), unusedImageIds()])
  .then(results => {
    const [rotatedImages, unusedImageIds] = results;
    return rotatedImages.filter(image => {
      return !unusedImageIds.includes(image.ImageId)
    })
  })
  .then(images => {
    const promises = images.map(image => {
      return deregisterImage(image).then(deleteSnapShot)
    });
    return Promise.all(promises);
  })
;
