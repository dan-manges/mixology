
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Iterator;
import java.util.List;
import java.util.ArrayList;

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
        RubyModule mixologyModule = runtime.defineModule("Mixology");
        CallbackFactory callbackFactory = runtime.callbackFactory(MixologyService.class);
        mixologyModule.definePublicModuleFunction("mixin", callbackFactory.getSingletonMethod("mixin", RubyModule.class));
        mixologyModule.definePublicModuleFunction("unmix", callbackFactory.getSingletonMethod("unmix", RubyModule.class));
	    	runtime.getObject().includeModule(mixologyModule);
        return true;
    }
    
    
		public static IRubyObject mixin(IRubyObject recv, RubyModule arg, Block block) {
        return arg.extend_object(recv);
    }

    public static IRubyObject unmix(IRubyObject recv, RubyModule arg, Block block) 
			throws NoSuchMethodException, IllegalAccessException, InvocationTargetException {
        for (RubyModule klass = recv.getMetaClass(); klass != recv.getMetaClass().getRealClass(); klass = klass.getSuperClass()) {
            if (klass.getSuperClass() != null &&  klass.getSuperClass().getNonIncludedClass() == arg) {
									setSuperClass(klass, klass.getSuperClass().getSuperClass());
									clearCache(recv.getRuntime(), klass, arg);	
						}
        }

        return recv.getRuntime().getNil();
    }

		protected static void setSuperClass(RubyModule klass, RubyModule superClass)
			throws NoSuchMethodException, IllegalAccessException, InvocationTargetException {
				Method setSuperClass = RubyModule.class.getDeclaredMethod("setSuperClass", new Class[] {RubyClass.class} );
				setSuperClass.setAccessible(true);
				Object[] newSuperClass = new Object[] { superClass };
				setSuperClass.invoke(klass, newSuperClass);
		}

		protected static void clearCache(final Ruby runtime, RubyModule klass, RubyModule module) {
			List methodNames = new ArrayList(module.getMethods().keySet());
      for (Iterator iter = methodNames.iterator();
      	iter.hasNext();) {
        String methodName = (String) iter.next();
        runtime.getCacheMap().remove(methodName, klass.searchMethod(methodName));
      }
		}
}
