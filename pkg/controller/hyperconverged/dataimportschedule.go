package hyperconverged

import (
	"fmt"
	"math/rand"
	"time"

	"github.com/kubevirt/hyperconverged-cluster-operator/pkg/controller/common"
)

var (
	// dataImportSchedule is the generated cron expression for the data import cron templates. HCO generates it only once
	// and updates the HyperConverged status.dataImportSchedule field if empty. If not empty, the status.dataImportSchedule
	// is the source for this variable.
	dataImportSchedule = ""
)

func applyDataImportSchedule(req *common.HcoRequest) {
	if req.Instance.Status.DataImportSchedule == "" {
		if dataImportSchedule == "" {
			dataImportSchedule = generateSchedule()
		}
		req.Instance.Status.DataImportSchedule = dataImportSchedule
		req.StatusDirty = true
	} else if req.Instance.Status.DataImportSchedule != dataImportSchedule {
		dataImportSchedule = req.Instance.Status.DataImportSchedule
	}
}

func generateSchedule() string {
	s := rand.NewSource(time.Now().UnixNano())
	r := rand.New(s)
	randMinute := r.Intn(60)
	return fmt.Sprintf("%d */12 * * *", randMinute)
}
