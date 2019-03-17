require 'time'

# The idea behind this is that in real life scenario it is likely that events
# are not fed at once but happening in real time. It would be ineffective to
# recalculate the whole tree every time, so the idea is that data is stored.
# For the sake of the test task I am not using a database, but in real example
# it would be used.
class Rewarding
  def initialize
    @users = {}
    @time = Time.new(0)
  end

  def push(data)
    records = validate parse(data)
    @time = records.last[:time]
    records.each do |record|
      case record[:verb]
      when 'recommends'
        recommend(record)
      when 'accepts'
        accept(record)
      end
    end
  end

  def rating
    @users
      .map { |user| [user[0], user[1][:reward]] }
      .select { |user| user[1] > 0 }
      .sort_by { |user| -user[1] }
      .to_h
  end

  def safe_time
    @time
  end

  def flush
    @users = {}
    @time = Time.new(0)
  end

  private

  def parse(data)
    data
      .split("\n")
      .map { |record| parse_record(record) }
      .sort_by { |record| record[:time] }
  end

  def parse_record(record)
    parsed = record
             .strip
             .scan(/^(\d{4}\-\d{2}\-\d{2}\s\d{2}:\d{2})\s(.*)\s(accepts|recommends)\s?(.*)$/)
             .first
    raise ParsingError if parsed.nil?

    form_record_hash parsed
  end

  def form_record_hash(parsed)
    begin
      {
        time: Time.parse(parsed[0]),
        actor_a: parsed[1],
        verb: parsed[2],
        actor_b: parsed[3]
      }
    rescue ArgumentError
      raise TimeFormatError
    end
  end

  def validate(records)
    raise TimeCollisionError if @time > records.first[:time]

    records
  end

  def recommend(record)
    return unless @users[record[:actor_b]].nil?

    @users[record[:actor_b]] = {
      invited_at: record[:time],
      invited_by: record[:actor_a],
      joined_at: nil,
      reward: 0
    }
    return unless @users[record[:actor_a]].nil?

    @users[record[:actor_a]] = {
      invited_at: nil,
      invited_by: nil,
      joined_at: Time.new(0),
      reward: 0
    }
  end

  def accept(record)
    if @users[record[:actor_a]].nil?
      @users[record[:actor_a]] = {
        invited_at: nil,
        invited_by: nil,
        joined_at: record[:time],
        reward: 0
      }
      return
    end
    return unless @users[record[:actor_a]][:joined_at].nil?

    @users[record[:actor_a]][:joined_at] = record[:time]
    set_reward(@users[record[:actor_a]][:invited_by], 1.0)
  end

  def set_reward(name, reward)
    return if name.nil? || @users[name].nil?

    @users[name][:reward] += reward
    set_reward(@users[name][:invited_by], reward / 2)
  end

  class TimeFormatError < RuntimeError
  end

  class TimeCollisionError < RuntimeError
  end

  class ParsingError < RuntimeError
  end
end
