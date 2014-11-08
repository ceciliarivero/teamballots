require "./app"
require "new_relic/rack/agent_hooks"
require "new_relic/rack/browser_monitoring"
use NewRelic::Rack::AgentHooks
use NewRelic::Rack::BrowserMonitoring

run Cuba
