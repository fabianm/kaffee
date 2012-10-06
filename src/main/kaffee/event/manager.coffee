# Copyright (c) 2012 Fabian M.
# See the AUTHORS file for all contributors of the Kaffee project.
LogEvent = require './logevent'
###
  The {@link EventManager} class manages events fired by Kaffee.

  @since 0.3.0
  @author Fabian M. <mail.fabianm@gmail.com>
###
class EventManager
	###
	  The name of this {@link EventManager}.
	###
	name: null

	###
	  An attachment object.
	###
	attachment: null

	###
	  The parent {@link EventManager}. of this {@link EventManager}.
	###
	parent: null

	###
	  The events of this {@link EventManager}.
	###
	events: {}
	
	###	
	  Constructs a new {@link EventManager} instance.
			
	  @since 0.3.0
	  @param name The name of this {@link EventManager}.
	  @param parent The parent {@link EventManager} instance.
	  @param attachment An attachment object.
	###
	constructor: (name, parent, attachment) -> 
		this.name = name
		this.parent = parent
		this.attachment = attachment
		this.events = {}
	###
	  Sets the name of this {@link EventManager}.

	  @since 0.3.0
	  @param name The name to set.
	###
	setName: (name) -> this.name = name
	
	###
	  Returns the name of this {@link EventManager}.

	  @since 0.3.0
	  @return The name of this {@link EventManager}.
	###
	getName: -> this.name

	###
	  Returns the attachment object of this {@link EventManager}.

	  @since 0.3.0
	  @return The attachment object of this {@link EventManager}.
	###
	getAttachment: -> this.attachment

	###
	  Sets the attachment object of this {@link EventManager}.

	  @since 0.3.0
	  @param attachment The attachment object to set.
	###
	setAttachment: (attachment) -> this.attachment = attachment

	###
	  Returns a logger object that provides basic logging functionality.

	  @since 0.3.0
	 
	  @return A logger object.
	###
	getLogger: -> ((manager) ->
		###
	 	  The Level object defines a set of standard logging levels that can be used to control logging output.

	  	  @since 0.3.0
		###
		this.Level = {
			ERROR : { name : 'error', value : 3},
			WARN : { name : 'warn', value : 2},
			DEBUG : { name : 'debug', value : 1},
			INFO : { name : 'info', value : 0 }
		}

		###
		  Logs a {@link LogEvent}.
	
	  	  @since 0.3.0
	 	  @param log The {@link LogEvent} to log.
		###
		this.log = (log) -> 
			manager.fire "#{ manager.getName() }:log" , log

		###
		  Logs a {@link Level#ERROR} message.

		  @since 0.3.0
		  @param message The message to log.
		###
		this.error = (message) -> 
			event = new LogEvent(manager, this.Level.ERROR, message)
			this.log event
			manager.fire "#{ manager.getName() }:error", message

		###
		  Logs a {@link Level#WARN} message.

		  @since 0.3.0
		  @param message The message to log.
		###
		this.warn = (message) -> 
			event = new LogEvent(manager, this.Level.WARN, message)
			this.log event
			manager.fire "#{ manager.getName() }:warn", message

		###
		  Logs a {@link Level#DEBUG} message.

		  @since 0.3.0
		  @param message The message to log.
		###
		this.debug = (message) -> 
			this.log new LogEvent(manager, this.Level.DEBUG, message)
			manager.fire "#{ manager.getName() }:debug", message

		###
		  Logs a {@link Level#INFO} message.

		  @since 0.3.0
		  @param message The message to log.
		###
		this.info = (message) -> 
			this.log new LogEvent(manager, this.Level.INFO, message)
			manager.fire "#{ manager.getName() }:info", message
		this
	) this
			
	###
	  Returns the parent {@link EventManager} of this {@link EventManager}.

	  @since 0.3.0
	  @return The parent {@link EventManager} of this {@link EventManager}.
	###
	getParent: -> this.parent

	###
	  Sets the parent {@link EventManager} of this {@link EventManager}.

	  @since 0.3.0
	  @param parent The parent {@link EventManager} to set.
	###
	setParent: (parent) -> this.parent = parent

	###
	  Returns the events of this {@link EventManager}.

	  @since 0.3.0
	  @return The events of this {@link EventManager}.
	###
	getEvents: -> this.events

	###
	  Returns the listeners of an event of this {@link EventManager}.

	  @since 0.3.0
	  @param name The name of the event.
	  @return The listeners of an event of this {@link EventManager}.
	###
	getListeners: (name) ->
		result = []
		regex = this.getRegex name
		for item, listeners of this.events
			if this.getRegex(item).test name || this.regex.test item
				result = result.concat listeners
		result

	###
	  Returns the RegEx of a string.

	  @since 0.3.0
	  @param str The string.
	  @return The RegEx.
	###
	getRegex: (str) ->
		new RegExp "^" + str.replace(new RegExp("[.*+?|()\\[\\]{}\\\\]", "g"), "\\$&").replace("\\*", ".*").replace("\\?", ".") + "$"

	###
	  Adds a listener to this {@link EventManager}.

	  @since 0.3.0
	  @param listener The listener to add.
	###
	addListener: (name, listener) -> 
		if typeof name == 'object'
			for key, value in name
				this.events[key] = [] if not this.events[key]
				this.events[key] = this.events[key].concat value
		if typeof name == 'array' && typeof listener == 'function'
			for key in name
				this.events[key] = [] if not this.events[key]
				this.events[key].push listener
		if typeof name == 'string' && typeof listener == 'function'
			this.events[name] = [] if not this.events[name]
			this.events[name].push listener
			
	###
	  @see EventManager#addListener(String, Function)
	###
	on: (name, listener) -> this.addListener name, listener

	###
	  Fires an event.

	  @since 0.3.0
	  @param name The name of the event to fire.
	  @param args The arguments.
	###
	fire: (name) ->
		return false if not name
		args = Array.prototype.slice.call arguments
		args.shift()
		listener.apply null, args for listener in this.getListeners(name)
		this.parent.fire.apply this.parent, Array.prototype.slice.call(arguments) if this.parent
module.exports = EventManager
