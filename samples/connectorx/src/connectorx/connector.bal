# Represents a X client.
# 
public client class Client {

    private string prop1;
    private string prop2;

    # Initializes the X client.
    # 
    # + prop1 - My first property
    # + prop2 - My second property
    public function init(string prop1, string prop2) returns error? {
        self.prop1 = prop1;
        self.prop2 = prop2;
    }

    public remote function echo(string msg) returns string {
        return msg;
    }

}
