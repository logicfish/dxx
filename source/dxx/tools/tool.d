module dxx.tools.tool;

import dxx.tools;

struct ToolOptions {
    string organisation;
    string projectName;
    string projectVersion;
    string symbolicName;
    string author;
    string license;
    string lang;
    string desc;
}

interface Tool {
    enum OK = 0;
    int run(string[] args);
}


