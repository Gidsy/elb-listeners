#!/usr/bin/env ruby
#
# Add listeners to Amazon ELB.
#
# Author: Fabrizio Sestito 
# Email: fabrizio@gidsy.com

require 'rubygems'
require 'aws-sdk'
require 'clamp'

def connect
    if not ENV['AMAZON_ACCESS_KEY_ID'] or not ENV['AMAZON_SECRET_ACCESS_KEY'] then
        puts 'Please export your AMAZON_ACCESS_KEY_ID and AMAZON_SECRET_ACCESS_KEY'
        return false
    end

    elb = AWS::ELB.new(
        :elb_endpoint => "eu-west-1.elasticloadbalancing.amazonaws.com",
        :access_key_id     => ENV['AMAZON_ACCESS_KEY_ID'],
        :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
    )
end

def list_balancers
    if elb = connect then
        return elb.load_balancers
    else
        puts 'Connection failed'
    end   
end

def get_balancer(balancer_id)
    if elb = connect then
        return elb.load_balancers[balancer_id]
    else
        puts 'Connection failed'
    end   
end

class ElbPort < Clamp::Command

    subcommand "add", "add listener to given balancer" do

        parameter "BALANCER_ID", "target balancer"
        parameter "LB_PROTOCOL", "load balancer protocol"
        parameter "LB_PORT", "load balancer port"
        parameter "IN_PROTOCOL", "instance protocol"
        parameter "IN_PORT", "instance port"
        option    ["-c", "--cert"], "CERT", "server certificate"

        def execute
            target_balancer = get_balancer(balancer_id)
            if target_balancer.exists? then
                target_balancer.listeners.create(:port => lb_port.to_i, :protocol => lb_protocol, 
                :instance_port => in_port.to_i, :instance_protocol => in_protocol, :server_certificate => cert)
            else
                puts "Balancer ID Invalid"
            end
        end
    end

    subcommand "list", "list load balancers" do
        def execute
            if balancers = list_balancers then
                balancers.each do |b|
                    puts "* #{b.name}"
                    b.listeners.each do |l|
                        puts "    - listening on port #{l.port}"
                    end
                end
            end
        end
    end

end

ElbPort.run