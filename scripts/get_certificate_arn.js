const AWS = require('aws-sdk');
const ArgumentParser = require('argparse').ArgumentParser;

AWS.config.region = process.env.AWS_DEFAULT_REGION;

function parseArguments() {
  const parser = new ArgumentParser({
    description: 'This script find an ACM arn by domain name',
  });
  parser.addArgument(['-d', '--domain'], {
    help: 'domain name of certificate to search',
    required: true,
  });
  return parser.parseArgs();
}

const args = parseArguments();
const ACM = new AWS.ACM();

ACM.listCertificates((err, data) => {
  const arn = data.CertificateSummaryList
    .filter(s => s.DomainName === args.domain)
    .map(s => s.CertificateArn);
  console.log(arn[0]);
});

