macOS managed folder lookup regression

These Elements/Oxygene projects test the built RTL2 assembly as an external consumer.
Build Elements.RTL.Echoes.elements and Elements.RTL.Echoes.Core.elements first.
MacFoldersConsumer.Framework.elements and MacFoldersConsumer.Core.elements default
to the corresponding RTL2 Bin/Echoes output; override --setting:RTL2Assembly with an
absolute Elements.dll path when testing isolated outputs.

Build MacFoldersNativeOracle.elements, then run its macOS executable. It prints
four expected paths in this order: user Application Support, user Caches, user
Library, and local Application Support. Pass those four lines as four separately
quoted arguments to MacFoldersConsumer.exe under Mono, or MacFoldersConsumer.dll
under dotnet. Use the same user and machine for oracle and managed runs.

The consumer checks all four public Environment properties on the main thread,
then repeats all four checks 100 times on a managed worker thread. It exits with
code 0 on success. The OS must be macOS; other operating systems print SKIP.

For the exit-hang regression, run each consumer under LLDB and set auto-continue
breakpoints on FSFindFolder, _CFVolumeObserverCreate, and
NSSearchPathForDirectoriesInDomains before launch. After a successful exit,
confirm that all breakpoints resolved and their hit counts are 0, 0, and 404.
These private Apple observer symbols may change on later macOS versions.

A healthy-system pass proves matching paths, worker-thread operation, normal
exit, and avoidance of the observed Carbon volume-observer trigger. It cannot
prove recovery from the original stuck backup mount or exclude other callers
creating their own volume observers.
