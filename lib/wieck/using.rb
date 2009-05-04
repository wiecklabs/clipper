module Kernel

  def using(object)
    raise ArgumentError.new("Kernel::using requires a block argument.") unless block_given?
    result = yield object
    object.dispose!
    result
  end

end