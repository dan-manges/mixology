import java.io.IOException;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyObject;
import org.jruby.RubyHash;
import org.jruby.RubyModule;
import org.jruby.RubyNumeric;
import org.jruby.RubyString;
import org.jruby.runtime.Block;
import org.jruby.runtime.CallbackFactory;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.exceptions.RaiseException;
import org.jruby.runtime.load.BasicLibraryService;

public class MixologyService implements BasicLibraryService {
    public boolean basicLoad(final Ruby runtime) throws IOException {
        Init_mixology_service(runtime);
        return true;
    }
    
    public IRubyObject mixin(IRubyObject recv, RubyModule arg, Block block) {
        return arg.extend_object(recv);
    }

    public IRubyObject unmix(IRubyObject recv, RubyModule args, Block block) {
        return recv.getRuntime().getNil();
    }


    public void Init_mixology_service(Ruby runtime) {
        RubyModule mixologyModule = runtime.defineModule("Mixology");
        CallbackFactory callbackFactory = runtime.callbackFactory(MixologyService.class);
        mixologyModule.definePublicModuleFunction("mixin", callbackFactory.getSingletonMethod("mixin", RubyModule.class));
        mixologyModule.definePublicModuleFunction("unmix", callbackFactory.getSingletonMethod("unmix", RubyModule.class));
				runtime.getObject().includeModule(mixologyModule);
    }
}
