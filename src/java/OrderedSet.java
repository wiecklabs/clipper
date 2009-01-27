import java.util.LinkedHashSet;
import org.jruby.Ruby;
import org.jruby.runtime.builtin.IRubyObject;

public class OrderedSet extends LinkedHashSet {

  private Object first = null;

  public Object first() {
    if ( this.first != null ) {
      return this.first;
    }
    else {
      return this.first = this.iterator().next();
    }
      
  }
}