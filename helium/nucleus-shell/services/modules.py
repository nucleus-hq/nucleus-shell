import sys

class ModuleRegistry:
    def __init__(self):
        self._modules = {}

    def init_modules(self, mappings: dict):
        # Populates the service registry with live interface object references.
        self._modules = mappings

    def __getattr__(self, name):
        if name in self._modules:
            return self._modules[name]
        raise AttributeError(f"Module '{name}' is not registered or initiated.")

# Inject instance into sys.modules so it can be imported cleanly anywhere
sys.modules[__name__] = ModuleRegistry()