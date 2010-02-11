#
# Author:: Kyle Maxwell
# Copyright:: Copyright (c) 2010 Kyle Maxwell
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


require File.join(File.dirname(__FILE__), '..', '..', '..', '/spec_helper.rb')

def setup_mocks(name)
  @ohai = Ohai::System.new    
  @ohai[:os] = "linux"
  @ohai[:network] = {}
  @ohai[:counters] = {}
  @ohai[:counters][:network] = {}
  @ohai.stub!(:require_plugin).and_return(true)
  @pid = 10
  @stdin = mock("STDIN", { :close => true })
  @stdout = File.open(File.dirname(__FILE__) + "/../../../fixtures/network/linux/#{name}", "r")
  @stderr = mock("STDERR")
  @ohai.stub!(:from).with("route -n | grep ^0.0.0.0 | awk '{print $8}'").and_return("eth0")
  @ohai.stub!(:popen4).with("ifconfig -a").and_yield(@pid, @stdin, @stdout, @stderr)
end

describe Ohai::System, "Linux network plugin" do
  
  context "a simple setup (one ip)" do
    before(:each) do
      setup_mocks("ifconfig_simple")
    end
    
    it "should correctly detect the ip address" do
      @ohai._require_plugin("linux::network")
      @ohai._require_plugin("network")
      @ohai[:ipaddress].should == "65.19.133.121"
    end
  end


  context "multiple ips per interface" do
    before(:each) do
      setup_mocks("ifconfig_multi")
    end
    
    it "should correctly detect the ip address" do
      @ohai._require_plugin("linux::network")
      @ohai._require_plugin("network")
      @ohai[:ipaddress].should == "65.19.133.114"
    end
  end
  
end