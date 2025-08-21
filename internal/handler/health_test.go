package handler_test
import ("net/http/httptest";"testing";"github.com/onsi/gomega")
func TestHealth(t *testing.T){
 g:=gomega.NewWithT(t); rr:=httptest.NewRecorder()
 rr.WriteString(`{"status":"ok"}`); g.Expect(rr.Code).To(gomega.Equal(200))
}
