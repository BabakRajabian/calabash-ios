require 'calabash-cucumber/utils/logging'

module Calabash
  module Cucumber
    module RotationHelpers  #=> Connection, StatusBarHelpers

      include Calabash::Cucumber::Logging

      # @!visibility private
      ROTATION_CANDIDATES = ['rotate_left_home_down',
                             'rotate_left_home_left',
                             'rotate_left_home_right',
                             'rotate_left_home_up',
                             'rotate_right_home_down',
                             'rotate_right_home_left',
                             'rotate_right_home_right',
                             'rotate_right_home_up']

      # orientations refer to home button position
      #  down ==> bottom
      #    up ==> top
      #  left ==> landscape with left home button AKA: _right_ landscape*
      # right ==> landscape with right home button AKA: _left_ landscape*
      #
      # * see apple documentation for clarification about where the home button
      #   is in left and right landscape orientations
      def rotate_home_button_to(dir)
        dir_sym = dir.to_sym
        if dir_sym.eql?(:top)
          if full_console_logging?
            calabash_warn "converting '#{dir}' to ':up' - please adjust your code"
          end
          dir_sym = :up
        end

        if dir_sym.eql?(:bottom)
          if full_console_logging?
            calabash_warn "converting '#{dir}' to ':down' - please adjust your code"
          end
          dir_sym = :down
        end

        directions = [:down, :up, :left, :right]
        unless directions.include?(dir_sym)
          screenshot_and_raise "expected one of '#{directions}' as an arg to 'rotate_home_button_to but found '#{dir}'"
        end

        res = status_bar_orientation()
        if res.nil?
          screenshot_and_raise "expected 'status_bar_orientation' to return a non-nil value"
        else
          res = res.to_sym
        end

        return res if res.eql? dir_sym

        ROTATION_CANDIDATES.each { |candidate|
          if full_console_logging?
            puts "try to rotate to '#{dir_sym}' using '#{candidate}'"
          end
          playback(candidate)
          sleep(0.4)

          res = status_bar_orientation
          if res.nil?
            screenshot_and_raise "expected 'status_bar_orientation' to return a non-nil value"
          else
            res = res.to_sym
          end

          return if res.eql? dir_sym
        }

        if full_console_logging?
          calabash_warn "Could not rotate home button to '#{dir}'."
          calabash_warn 'Is rotation enabled for this controller?'
          calabash_warn "Will return 'down'"
        end
        :down
      end

      def rotate(dir)
        dir = dir.to_sym
        current_orientation = status_bar_orientation().to_sym
        rotate_cmd = nil
        case dir
          when :left then
            if current_orientation == :down
              rotate_cmd = 'left_home_down'
            elsif current_orientation == :right
              rotate_cmd = 'left_home_right'
            elsif current_orientation == :left
              rotate_cmd = 'left_home_left'
            elsif current_orientation == :up
              rotate_cmd = 'left_home_up'
            end
          when :right then
            if current_orientation == :down
              rotate_cmd = 'right_home_down'
            elsif current_orientation == :left
              rotate_cmd = 'right_home_left'
            elsif current_orientation == :right
              rotate_cmd = 'right_home_right'
            elsif current_orientation == :up
              rotate_cmd = 'right_home_up'
            end
        end

        if rotate_cmd.nil?
          if full_console_logging?
            puts "Could not rotate device in direction '#{dir}' with orientation '#{current_orientation} - will do nothing"
          end
        else
          playback("rotate_#{rotate_cmd}")
        end
      end

    end
  end
end