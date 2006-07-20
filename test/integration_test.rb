require 'test_helper'

require 'yaml'

class IntegrationTest < Test::Unit::TestCase
  def setup
    FileUtils.rm_rf HOME
  end

  def teardown
    FileUtils.rm_rf HOME
  end

  def test_add_project_as_url
    output = run_cerb("  add   #{SVN_URL}  ")
    assert_match /was successfully added/, output
    assert File.exists?(HOME + '/config/svn_repo.yml')
    assert_equal SVN_URL, load_yml(HOME + '/config/svn_repo.yml')['url']

    #try to add second time
    output = run_cerb("add #{SVN_URL}")
    assert_match /already present/, output
    assert File.exists?(HOME + '/config/svn_repo.yml')
    assert_equal SVN_URL, load_yml(HOME + '/config/svn_repo.yml')['url']
  end

  def test_add_project_with_parameters
    output = run_cerb("  add   #{SVN_URL}  APPLICATION_NAME=hello_world RECIPIENTS=aa@gmail.com")
    assert_match /was successfully added/, output

    assert File.exists?(HOME + '/config/hello_world.yml')
    cfg = load_yml(HOME + '/config/hello_world.yml')

    assert_equal SVN_URL, cfg['url']
    assert_equal 'aa@gmail.com', cfg['recipients']
  end

  def test_run_project
    add_application('svn_repo', SVN_URL, 'quiet' => true)

    run_cerb("build svn_repo")
    assert File.exists?(HOME + '/work/svn_repo/status.log')
    assert_equal 'succesful', IO.read(HOME + '/work/svn_repo/status.log')
  end

  def test_run_unexist_project
    output = run_cerb("build some_project")
    assert_equal 'Project some_project does not present in Cerberus', output.strip
    assert !test(?d, HOME + '/work/some_project')
  end
end