require 'Benchmark'
require 'active_support/concern'
require 'action_view/helpers/capture_helper'
require 'action_view/helpers/tag_helper'
class MyTestClass

end
class EagerLoadingTest
  include ActionView::Helpers::TagHelper
  ITERATION = 100_000

  def is_a_test
    m = MyTestClass.new
    Benchmark.bm(27) do |bm|
      bm.report('is_a') do
        ITERATION.times do
          m.is_a?(MyTestClass)
        end
      end

      bm.report('no comparison') do
        ITERATION.times do
          m.class.eql? MyTestClass
        end
      end
    end
  end

  def delete_at_test
    ary = ITERATION.times.map{|x| x}
    Benchmark.bm(27) do |bm|
      bm.report('is_a') do
        ITERATION.times do
          ary.delete_at(0)
        end
      end

      bm.report('no comparison') do
        ITERATION.times do

        end
      end
    end
  end

  def at_test
    ary = ITERATION.times.map{|x| x}
    Benchmark.bm(27) do |bm|
      bm.report('is_a') do
        ITERATION.times do
          ary.at(0)
        end
      end

      bm.report('no comparison') do
        ITERATION.times do
          ary[0]
        end
      end
    end
  end

  def content_tag_test
    Benchmark.bm(27) do |bm|
      bm.report('content_tag :b') do
        ITERATION.times do
          content_tag :b, 'aa'
        end
      end

      bm.report('<b>') do
        ITERATION.times do
          '<b>aaa</b>'
        end
      end
    end
  end

end

test = EagerLoadingTest.new

test.content_tag_test
