require 'spec_helper'

def read_json_fixture(filename)
  spec_dir = File.dirname(__dir__)
  filename = File.join(spec_dir, 'fixtures', filename)
  JSON.parse(File.read(filename))
end

describe CfnDsl::CloudFormationTemplate do
  subject(:template) { described_class.new }

  it 'CodePipeline_Pipeline' do
    template.CodePipeline_Pipeline(:Test) do
      ArtifactStore(Location: 's3://asdf', Type: 'S3')
      Name 'TestPipeline'
      RestartExecutionOnUpdate true
      RoleArn 'arn:::::asdf'
      Stages([
               Actions: [],
               Blockers: [],
               Name: 'ANiceName'
             ])
    end
    expect(JSON.parse(template.to_json)).to eq(read_json_fixture('codepipeline-pipeline.json'))
  end

  it 'CodePipeline_CustomActionType' do
    template.CodePipeline_CustomActionType(:Test) do
      Category 'String'
      ConfigurationProperties(
        Description: 'a nice description',
        Queryable: true,
        Type: 'NiceType'
      )
      InputArtifactDetails {}
      OutputArtifactDetails {}
      Provider 'asdf'
      Settings {}
      Version '1.1.1'
    end
    # File.open('/tmp/dum', 'w') { |f| f.write(template.to_json) }
    expect(JSON.parse(template.to_json)).to eq(read_json_fixture('codepipeline-customactiontype.json'))
  end
end
