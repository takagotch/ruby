class Bucket
  def initialize(limit = 5)
    @appendable = ConditionVariable.new # 出力されるまで待つためのもの
    @flushable  = ConditionVariable.new # 行数が一定数に達するまで待つためのもの
    @lock  = Mutex.new # @out のロック
    @limit = limit     # @out の行数が @limit に達したら @flushable になる
    @out   = ''        # 出力される文字列
  end

  def append(str)
    @lock.synchronize {
      @appendable.wait(@lock) unless appendable?

      @out << str

      @flushable.signal if flashable?
    }
  end

  def flush
    @lock.synchronize {
      @flushable.wait(@lock) unless flashable?

      puts '-' * 10
      puts @out

      @out = ''
      @appendable.signal if appendable?
    }
  end

  private

  def appendable?
    @out.lines.count < @limit
  end

  def flashable?
    !appendable?
  end
end
