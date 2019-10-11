function Component() {}


Component.prototype.createOperations = function() {
    component.createOperations();

    if(systemInfo.productType === "windows") {
        component.addElevatedOperation("Execute", "{0,3010,1638,5100}", "@TargetDir@/gh-greets-qt/vc_redist.x64.exe", "/quiet", "/norestart");

        component.addOperation(
            "CreateShortcut",
            "@TargetDir@/gh-greets-qt/gh-greets-qt.exe",
            "@StartMenuDir@/Hi-Qt.lnk",
            "workingDirectory=@TargetDir@"
        );
    }
}
