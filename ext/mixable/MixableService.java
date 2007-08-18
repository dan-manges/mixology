import java.io.IOException;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyHash;
import org.jruby.RubyModule;
import org.jruby.RubyNumeric;
import org.jruby.RubyString;
import org.jruby.runtime.Block;
import org.jruby.runtime.CallbackFactory;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.exceptions.RaiseException;
import org.jruby.runtime.load.BasicLibraryService;

public class MixableService implements BasicLibraryService {
    public boolean basicLoad(final Ruby runtime) throws IOException {
        Init_mixable(runtime);
        return true;
    }
    
    public static IRubyObject mixin(IRubyObject recv, RubyModule arg, Block block) {
        return arg.extend_object(recv);
    }

    public static IRubyObject unmix(IRubyObject recv, RubyModule args, Block block) {
        return recv.getRuntime().getNil();
    }


    public static void Init_mixable(Ruby runtime) {
        RubyModule mixableModule = runtime.defineModule("Mixable");
        CallbackFactory callbackFactory = runtime.callbackFactory(MixableService.class);
        mixableModule.definePublicModuleFunction("mixin", callbackFactory.getSingletonMethod("mixin", RubyModule.class));
        mixableModule.definePublicModuleFunction("unmix", callbackFactory.getSingletonMethod("unmix", RubyModule.class));
    }
}
