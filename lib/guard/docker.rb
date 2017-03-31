require 'guard'

module Guard
  class Docker < Plugin

    # Initializes a Guard plugin.
    # Don't do any work here, especially as Guard plugins get initialized even if they are not in an active group!
    #
    # @param [Hash] options the custom Guard plugin options
    # @option options [Array<Guard::Watcher>] watchers the Guard plugin file watchers
    # @option options [Symbol] group the group this Guard plugin belongs to
    # @option options [Boolean] any_return allow any object to be returned from a watcher
    #
    def initialize(options = {})
      
      @image = options.fetch(:image, nil)
      @tag = options.fetch(:tag, nil)
      @host_port = options.fetch(:host_port, nil)
      @container_port = options.fetch(:container_port, nil)
      @env_vars = options.fetch(:env_vars, nil)

      super
    end

    # Called once when Guard starts. Please override initialize method to init stuff.
    #
    # @raise [:task_has_failed] when start has failed
    # @return [Object] the task result
    #
    def start
      failed 'You must specify an image' unless @image
      return false unless @image

      stop

      cmd = []
      cmd << 'docker run --rm'
      cmd << "-p #{@host_port}:#{@container_port}" if @host_port && @container_port

      @env_vars.each do |key, value|
        cmd << "-e #{key}=#{value}"
      end if @env_vars

      if @tag
        cmd << "--name=guard-#{@image}-#{@tag}"
        cmd << "#{@image}:#{@tag}"
      else
        cmd << "--name=guard-#{@image}"
        cmd << @image
      end

      spawn(cmd.join(' '))

      success "#{@image} is running"
    end

    # Called when `stop|quit|exit|s|q|e + enter` is pressed (when Guard quits).
    #
    # @raise [:task_has_failed] when stop has failed
    # @return [Object] the task result
    #
    def stop
      cmd = []
      cmd << 'docker stop'
      cmd << "guard-#{@image}" if !@tag
      cmd << "guard-#{@image}-#{@tag}" if @tag
      system(cmd.join(' '))
    end

    # Called when `reload|r|z + enter` is pressed.
    # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    #
    # @raise [:task_has_failed] when reload has failed
    # @return [Object] the task result
    #
    def reload
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    #
    # @raise [:task_has_failed] when run_all has failed
    # @return [Object] the task result
    #
    def run_all
    end

    # Called on file(s) additions that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_additions has failed
    # @return [Object] the task result
    #
    def run_on_additions(paths)
    end

    # Called on file(s) modifications that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_modifications has failed
    # @return [Object] the task result
    #
    def run_on_modifications(paths)
    end

    # Called on file(s) removals that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_removals has failed
    # @return [Object] the task result
    #
    def run_on_removals(paths)
    end

    def pending message
      notify message, :image => :pending
    end

    def success message
      notify message, :image => :success
    end

    def failed message
      notify message, :image => :failed
    end

    def notify(message, options = {})
      Notifier.notify(message, options)
    end

  end
end
