#!/usr/bin/env bash
export PYTHONUNBUFFERED=1

echo "Container is running"

# Sync venv to workspace to support Network volumes
echo "Syncing venv to workspace, please wait..."
rsync -au /venv/ /workspace/venv/

# Sync FaceFusion to workspace to support Network volumes
echo "Syncing FaceFusion to workspace, please wait..."
rsync -au /facefusion/ /workspace/facefusion/

# Fix the venv to make it work from /workspace
echo "Fixing venv..."
/fix_venv.sh /venv /workspace/venv

if [[ ${DISABLE_AUTOLAUNCH} ]]
then
    echo "Auto launching is disabled so the application will not be started automatically"
    echo "You can launch it manually:"
    echo ""
    echo "   cd /workspace/facefusion"
    echo "   deactivate && source /workspace/venv/bin/activate"
    echo "   export GRADIO_SERVER_NAME=\"0.0.0.0\""
    echo "   export GRADIO_SERVER_PORT=\"3001\""
    echo "   python3 run.py --execution-providers cuda"
else
    mkdir -p /workspace/logs
    echo "Starting FaceFusion"
    export HF_HOME="/workspace"
    source /workspace/venv/bin/activate
    cd /workspace/facefusion
    export GRADIO_SERVER_NAME="0.0.0.0"
    export GRADIO_SERVER_PORT="3001"
    nohup python3 run.py --execution-providers cuda > /workspace/logs/facefusion.log 2>&1 &
    echo "FaceFusion started"
    echo "Log file: /workspace/logs/facefusion.log"
    deactivate
fi

echo "All services have been started"