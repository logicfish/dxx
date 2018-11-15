module dxx.app.document;

interface DocumentType {
}

interface Document(Root) {
    Root docRoot();
    DocumentType docType();
}


