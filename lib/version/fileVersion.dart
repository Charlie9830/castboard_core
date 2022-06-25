///
///     IMPORTANT
///
/// If you are enumerating this value, ensure you add a corresponsing version migration function to the [ImportedShowData] class,
/// even if it is just a NOOP style function. Otherwise you can end up breaking the Cascade Migration logic in the [ensureMigrated] method.
const int kMaxAllowedFileVersion = 2;
