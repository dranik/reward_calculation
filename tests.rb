require_relative 'rewarding'
require 'test/unit'

# tests
class TestRewarding < Test::Unit::TestCase
  def rewarding(data)
    rewarding = Rewarding.new
    rewarding.push data
    rewarding.rating
  end

  def test_initial
    assert_equal(
      { 'A' => 1.75, 'B' => 1.5, 'C' => 1.0 },
      rewarding('2018-06-12 09:41 A recommends B
                 2018-06-14 09:41 B accepts
                 2018-06-16 09:41 B recommends C
                 2018-06-17 09:41 C accepts
                 2018-06-19 09:41 C recommends D
                 2018-06-23 09:41 B recommends D
                 2018-06-25 09:41 D accepts')
    )
  end

  def test_no_one_accepts
    assert_equal(
      {},
      rewarding('2018-06-12 09:41 A recommends B
                 2018-06-16 09:41 B recommends C
                 2018-06-19 09:41 C recommends D
                 2018-06-23 09:41 B recommends D')
    )
  end

  def test_humans
    assert_equal(
      { 'Chris Isaac' => 1.75,
        'Jean-Claude Van Damme' => 1.5,
        'Janice Joplin' => 1.0 },
      rewarding('2018-06-12 09:41 Chris Isaac recommends Jean-Claude Van Damme
                 2018-06-14 09:41 Jean-Claude Van Damme accepts
                 2018-06-16 09:41 Jean-Claude Van Damme recommends Janice Joplin
                 2018-06-17 09:41 Janice Joplin accepts
                 2018-06-19 09:41 Janice Joplin recommends Wu Zetian
                 2018-06-23 09:41 Jean-Claude Van Damme recommends Wu Zetian
                 2018-06-25 09:41 Wu Zetian accepts')
    )
  end

  def test_loop
    assert_equal(
      { 'A' => 1.75, 'B' => 1.5, 'C' => 1.0 },
      rewarding('2018-06-12 09:41 A recommends B
                 2018-06-14 09:41 B accepts
                 2018-06-16 09:41 B recommends C
                 2018-06-17 09:41 C accepts
                 2018-06-19 09:41 C recommends D
                 2018-06-23 09:41 B recommends D
                 2018-06-25 09:41 C recommends A
                 2018-06-25 09:41 D accepts')
    )
  end

  def test_wrong_verb
    data = '2018-06-12 09:41 A recommends B
            2018-06-14 09:41 B accpts'
    assert_raises Rewarding::ParsingError do
      rewarding(data)
    end
  end

  def test_wrong_time
    data = '2099-06-99 09:41 A recommends B
            2018-06-14 09:41 B accepts'
    assert_raises Rewarding::TimeFormatError do
      rewarding(data)
    end
  end

  def test_many_children
    assert_equal(
      { 'A' => 4.5, 'D' => 3.0 },
      rewarding('2018-06-12 09:41 A recommends B
                 2018-06-13 09:41 A recommends C
                 2018-06-13 09:41 A recommends D
                 2018-06-14 09:41 B accepts
                 2018-06-17 09:41 C accepts
                 2018-06-21 09:41 D accepts
                 2018-06-23 09:41 D recommends E
                 2018-06-23 09:41 D recommends F
                 2018-06-23 09:41 D recommends G
                 2018-06-25 09:41 E accepts
                 2018-06-25 09:41 F accepts
                 2018-06-25 09:41 G accepts')
    )
  end

  # The idea behind the solution that I am proposing is that set of users might
  # be updated and this will make the algorithm to update rewards
  def test_double_push
    rewarding = Rewarding.new
    rewarding.push '2018-06-12 09:41 A recommends B
                    2018-06-14 09:41 B accepts
                    2018-06-16 09:41 B recommends C
                    2018-06-17 09:41 C accepts
                    2018-06-19 09:41 C recommends D
                    2018-06-23 09:41 B recommends D
                    2018-06-25 09:41 D accepts'
    rewarding.push '2018-07-12 08:41 D recommends Chris Isaac
                    2018-07-12 09:21 Chris Isaac accepts
                    2018-07-12 09:41 Chris Isaac recommends Jean-Claude Van Damme
                    2018-07-14 09:41 Jean-Claude Van Damme accepts
                    2018-07-16 09:41 Jean-Claude Van Damme recommends Janice Joplin
                    2018-07-17 09:41 Janice Joplin accepts
                    2018-07-19 09:41 Janice Joplin recommends Wu Zetian
                    2018-07-23 09:41 Jean-Claude Van Damme recommends Wu Zetian
                    2018-07-25 09:41 Wu Zetian accepts'
    assert_equal(
      { 'A' => 1.984375,
        'B' => 1.96875,
        'C' => 1.9375,
        'D' => 1.875,
        'Chris Isaac' => 1.75,
        'Jean-Claude Van Damme' => 1.5,
        'Janice Joplin' => 1.0 },
      rewarding.rating
    )
  end

  # One of the problem that my algorithm has is that the user at the root of the
  # tree has no defined acceptance date
  # So, if new events are dated before any events pushed previously, the
  # exception will be raised
  def test_collision
    rewarding = Rewarding.new
    rewarding.push '2018-06-12 09:41 A recommends B
                    2018-06-14 09:41 B accepts
                    2018-06-16 09:41 B recommends C
                    2018-06-17 09:41 C accepts
                    2018-06-19 09:41 C recommends D
                    2018-06-23 09:41 B recommends D
                    2018-06-25 09:41 D accepts'
    assert_raises Rewarding::TimeCollisionError do
      rewarding.push '2016-09-12 09:41 D recommends A'
    end
  end
end
