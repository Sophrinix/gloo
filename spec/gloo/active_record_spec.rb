require File.dirname(__FILE__) + '/../spec_helper'
require 'gloo/active_record'

describe Gloo::ActiveRecord do
  before(:each) do
     Object.send(:remove_const, :GlooModel) if defined? GlooModel
    class GlooModel
      include Gloo::ActiveRecord
      attr_accessor :user_id, :id
    end
  end
  
  it 'should provide a .gloo method to the class' do
    GlooModel.should be_respond_to(:gloo)
  end
  
  describe ' belongs_to' do
    it 'should be available' do
      GlooModel.should be_respond_to(:_activerecord_belongs_to)
    end

    it 'should define appropriate methods after being called' do
      GlooModel.gloo :active_record do
        belongs_to :user
      end

      %w(user user= create_user).each do |meth|
	GlooModel.instance_methods.should be_include(meth)
      end
    end
    
    describe ' with default foreign and primary keys' do
      before(:each) do
        GlooModel.gloo :active_record do
          belongs_to :user
        end
      end
      
      it '#<association> should return an ActiveRecord with the specified ID' do
        g = GlooModel.new
        u = User.create
        g.user_id = u.id
        g.user.should == u
      end
      
      it '#<association>= should set the foreign key appropriately' do
        g = GlooModel.new
        u = User.create
        g.user = u
        g.user_id.should == u.id
      end
    end
  end
  
  describe ' has_many' do
    it 'should be available' do
      GlooModel.should be_respond_to(:_activerecord_has_many)
    end
    
    it 'should define appropriate methods after being called' do
      GlooModel.gloo :active_record do
        has_many :comments
      end
      
      %w(comments comments= comment_ids comment_ids=).each do |meth|
        GlooModel.instance_methods.should be_include(meth)
      end
    end
    
    describe ' with default options' do
      before(:each) do
        Comment.delete_all
        GlooModel.gloo :active_record do
          has_many :comments
        end
      end
      
      it "#<association> should return all ActiveRecords with this model's id" do
        g = GlooModel.new
        g.id = 'bob'
        7.times{ Comment.create(:gloo_model_id => 'bob')}
        g.comments.size.should == 7
      end
      
      it '#<association>= should associate the specified models with this model' do
        g = GlooModel.new
        g.id = 'frank'
        comments = [Comment.create, Comment.create, Comment.create]
        g.comments = comments
        comments.each {|c| c.reload.gloo_model_id.should == 'frank'}
      end
    end
  end
end
