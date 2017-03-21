
require 'cfndsl/aws/generator'

describe 'AWS type generator' do
  it 'load_spec_file' do
    filename = fixture_filename('spec.json')
    data = load_spec_file(filename)
    expected = %w(PropertyTypes ResourceTypes ResourceSpecificationVersion)
    expect(data.keys()).to eq(expected)
  end

  subject(:spec) { load_spec_file(fixture_filename('spec.json')) }
  it 'resources' do
    expect(resources(spec).keys()[0]).to eq('AWS::ElasticBeanstalk::ConfigurationTemplate')
  end

  it 'properties' do
    resources = resources(spec)
    name = resources.keys()[0]
    keys = %w(ApplicationName Description EnvironmentId OptionSettings SolutionStackName SourceConfiguration)
    expect(properties(resources[name]).keys()).to eq(keys)
  end

  it 'property_type' do
    resources = resources(spec)
    name = resources.keys()[0]
    props = properties(resources[name])
    types = props.map { |name, p| property_type(p) }
    expected = ['String', 'String', 'String', ['ConfigurationOptionSetting'], 'String', 'SourceConfiguration']
    expect(types).to eq(expected)
  end

  it 'property_types' do
    resources = resources(spec)
    name = resources.keys()[0]
    types = property_types(resources[name])
    expected = {'ApplicationName'=>'String', 'Description'=>'String', 'EnvironmentId'=>'String',
                'OptionSettings'=>['ConfigurationOptionSetting'], 'SolutionStackName'=>'String',
                'SourceConfiguration'=>'SourceConfiguration'}
    expect(types).to eq(expected)
  end

  it 'ordered' do
    d = {b:1, c:2, a:1}
    expect(ordered(d)).to eq({a:1, b:1, c:2})
  end
  it 'generate' do
    types = { a: 1 }
    spec = { ResourceTypes: types }
    expect(resources(spec)).to eq(types)
  end

  it 'spec_to_cfndsl_type_name' do
    names = ['AWS::CodeBuild::Project.Artifacts',
             'AWS::ElasticBeanstalk::ConfigurationTemplate.ConfigurationOptionSetting',
             'AWS::EC2::SpotFleet.IamInstanceProfile',
             'AWS::CodePipeline::Pipeline.InputArtifact',
             'AWS::SNS::Topic.Subscription',
             'AWS::CodePipeline::Pipeline.ArtifactStore',
             'AWS::AutoScaling::AutoScalingGroup.MetricsCollection',
             'AWS::DynamoDB::Table.KeySchema',
             'AWS::S3::Bucket.ReplicationConfiguration',
             'AWS::S3::Bucket.NotificationFilter',
             'AWS::DataPipeline::Pipeline.ParameterAttribute',
             'AWS::CloudFront::Distribution.ViewerCertificate',
             'AWS::EMR::Cluster.Configuration',
             'AWS::CertificateManager::Certificate.DomainValidationOption',
             'AWS::ECS::TaskDefinition.HostEntry',
             'AWS::S3::Bucket.Rule',
             'AWS::S3::Bucket.RoutingRuleCondition',
             'AWS::S3::Bucket.QueueConfiguration',
             'AWS::KinesisFirehose::DeliveryStream.ElasticsearchDestinationConfiguration',
             'AWS::ElasticLoadBalancing::LoadBalancer.Listeners',
             'AWS::S3::Bucket.LifecycleConfiguration',
             'AWS::AutoScaling::LaunchConfiguration.BlockDeviceMapping',
             'AWS::S3::Bucket.TopicConfiguration',
             'AWS::CloudFront::Distribution.S3OriginConfig',
             'AWS::ElasticLoadBalancingV2::LoadBalancer.LoadBalancerAttribute']
    expected = ['Artifacts', 'ConfigurationOptionSetting', 'IamInstanceProfile', 'InputArtifact',
                'Subscription', 'ArtifactStore', 'MetricsCollection', 'KeySchema',
                'ReplicationConfiguration', 'NotificationFilter', 'ParameterAttribute',
                'ViewerCertificate', 'Configuration', 'DomainValidationOption', 'HostEntry',
                'Rule', 'RoutingRuleCondition', 'QueueConfiguration', 'ElasticsearchDestinationConfiguration',
                'Listeners', 'LifecycleConfiguration', 'BlockDeviceMapping', 'TopicConfiguration',
                'S3OriginConfig', 'LoadBalancerAttribute']
    actual = names.map { |n| spec_to_cfndsl_type_name n }
    save_data(actual)
    expect(actual).to eq(expected)
  end
end
