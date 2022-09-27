# frozen_string_literal: true
require 'net/http'
require 'uri'
require 'json'
require 'date'

require_relative "github_notion_changelog/version"

module GithubNotionChangelog
  class Error < StandardError; end
  
  def self.create(tag_name)
    tag_command = %x[ git tag #{tag_name} && git push origin #{tag_name} ]
    release_command = %x[ gh release create #{tag_name} --generate-notes ]

    uri = URI.parse("https://api.notion.com/v1/pages/")
    record = { 
      parent: { 
        type: "database_id", database_id: "e2efadce324a452892aa8863c31fb115" 
      }, 
      properties: { 
        Version: {
          title: [
            {
              type: "text",
              text: {
                content: tag_name,
              }
            }
          ],
        }, 
        Release_Date: {
          date: {
            start: DateTime.now.iso8601,
          }  
        }, 
      },
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["accept"] = 'application/json'
    request["Notion-Version"] = '2022-06-28'
    request["content-type"] = 'application/json'
    request["authorization"] = 'Bearer secret_NRnM5Lp1Nm19DNL2wAYYdgLdjG1tXqK5uO9ziWa3LQu'
    request.body = record.to_json

    response = http.request(request)

    puts response.read_body

  end
end
