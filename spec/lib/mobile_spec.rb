require 'spec_helper'
require 'script_loader'

describe "Mobile" do

  HOST = "127.0.0.1"

  before :all do
    ScriptLoader.load
    @redis = Redis.new(host: HOST, port: "6379")
    @redis.flushdb
    @date = Date.today.strftime("%Y-%m-%d")
    @params = { id: 1, locale: "en", team_id: 23, article_pn: 1, match_pn: 1 }
  end

  def hash_to_query_string(hash)
    hash.map { |k,v| "#{k}=#{v}" }.join("&")
  end

  describe "Active" do
    before :all do
      @params[:action] = "active"
      @end_point = "http://#{HOST}/mobile?#{hash_to_query_string(@params)}"
      @key_prefix = "mobile_activity"
      @key_prefix_long = "mobile_activity_#{@params[:locale]}_team_#{@params[:team_id]}"
      `curl '#{@end_point}'`
    end
    
    it "should set the bit in the map according to the device id, date, locale and team" do
      @redis.getbit("#{@key_prefix_long}_article_pn_#{@params[:article_pn]}_#{@date}", @params[:id]).should eq 1
      @redis.getbit("#{@key_prefix_long}_article_pn_#{@params[:match_pn]}_#{@date}", @params[:id]).should eq 1
    end

    it "should set the bit in the general map according to the device id and date" do
      @redis.getbit("#{@key_prefix}_article_pn_#{@params[:article_pn]}_#{@date}", @params[:id]).should eq 1
      @redis.getbit("#{@key_prefix}_article_pn_#{@params[:match_pn]}_#{@date}", @params[:id]).should eq 1        
    end

    describe "Using same bitmap" do
      before :all do
        @params[:id] = "7"
        @end_point = "http://#{HOST}/mobile?#{hash_to_query_string(@params)}"
        @redis.bitcount("#{@key_prefix_long}_article_pn_#{@params[:article_pn]}_#{@date}").should eq 1
        @redis.bitcount("#{@key_prefix_long}_article_pn_#{@params[:match_pn]}_#{@date}").should eq 1
        @redis.bitcount("#{@key_prefix}_article_pn_#{@params[:article_pn]}_#{@date}").should eq 1
        @redis.bitcount("#{@key_prefix}_article_pn_#{@params[:match_pn]}_#{@date}").should eq 1
        `curl '#{@end_point}'`
      end
      
      it "should set the bit in the same map as in previous spec, but for a different bit" do
        @redis.bitcount("#{@key_prefix_long}_article_pn_#{@params[:article_pn]}_#{@date}").should eq 2
        @redis.bitcount("#{@key_prefix_long}_article_pn_#{@params[:match_pn]}_#{@date}").should eq 2
        @redis.bitcount("#{@key_prefix}_article_pn_#{@params[:article_pn]}_#{@date}").should eq 2
        @redis.bitcount("#{@key_prefix}_article_pn_#{@params[:match_pn]}_#{@date}").should eq 2
      end
    end
  end


  describe "Push Notification Received" do
    before :all do
      @params[:action] = "pn_received"
      @end_point = "http://#{HOST}/mobile?#{hash_to_query_string(@params)}"
    end

    it "should increase by 1 the PN Received counter according to the device id, date, locale and team" do
      key = "pn_received_#{@params[:locale]}_team_#{@params[:team_id]}_#{@date}"
      value = @redis.get(key) || 0
      `curl '#{@end_point}'`
      @redis.get(key).to_i.should eq value.to_i + 1
    end

    it "should increase by 1 the general PN Received counter according to the device id, date" do
      key = "pn_received_#{@date}"
      value = @redis.get(key) || 0
      `curl '#{@end_point}'`
      @redis.get(key).to_i.should eq value.to_i + 1      
    end
  end


  describe "Push Notification Clicked" do
    before :all do
      @params[:action] = "pn_clicked"
      @end_point = "http://#{HOST}/mobile?#{hash_to_query_string(@params)}"
    end

    it "should increase by 1 the PN Received counter according to the device id, date, locale and team" do
      key = "pn_clicked_#{@params[:locale]}_team_#{@params[:team_id]}_#{@date}"
      value = @redis.get(key) || 0
      `curl '#{@end_point}'`
      @redis.get(key).to_i.should eq value.to_i + 1
    end

    it "should increase by 1 the general PN Received counter according to the device id, date" do
      key = "pn_clicked_#{@date}"
      value = @redis.get(key) || 0
      `curl '#{@end_point}'`
      @redis.get(key).to_i.should eq value.to_i + 1      
    end
  end


  describe "Push Notification Opened" do
    before :all do
      @params[:action] = "pn_opened"
      @end_point = "http://#{HOST}/mobile?#{hash_to_query_string(@params)}"
    end

    it "should increase by 1 the PN Received counter according to the device id, date, locale and team" do
      key = "pn_opened_#{@params[:locale]}_team_#{@params[:team_id]}_#{@date}"
      value = @redis.get(key) || 0
      `curl '#{@end_point}'`
      @redis.get(key).to_i.should eq value.to_i + 1
    end

    it "should increase by 1 the general PN Received counter according to the device id, date" do
      key = "pn_opened_#{@date}"
      value = @redis.get(key) || 0
      `curl '#{@end_point}'`
      @redis.get(key).to_i.should eq value.to_i + 1      
    end
  end  

end
