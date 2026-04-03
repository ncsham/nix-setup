# Shell helper functions (kubectl, docker, port check, etc.) written to ~/.functions.
{ ... }:
{
  home.file.".functions".text = ''
    # Nix Functions
    nug() {
      local flake='/private/etc/nix-darwin#darwin'
      sudo /usr/bin/env USER="$USER" darwin-rebuild switch --impure --flake "$flake"
    }
    nugp() {
      local flake='/private/etc/nix-darwin#darwin'
      sudo /usr/bin/env USER="$USER" darwin-rebuild build --impure --flake "$flake" \
        && nix store diff-closures /nix/var/nix/profiles/system /private/etc/nix-darwin/result
    }
    sysugp() { nugp; }
    sysug() { brew upgrade && brew cleanup && nug; }

    # Kubectl convenience functions
    function ktp() {
      if [ $# -ne 2 ]; then
        echo "Usage: ktp <namespace> <pod-name>"
        return 1
      fi
      kubecolor logs -f "$2" -n "$1"
    }

    function klp() {
      if [ $# -ne 2 ]; then
        echo "Usage: klp <namespace> <pod-name>"
        return 1
      fi
      kubecolor logs "$2" -n "$1"
    }

    function kep() {
      if [ $# -ne 2 ]; then
        echo "Usage: kep <namespace> <pod-name>"
        return 1
      fi
      kubecolor exec -it "$2" -n "$1" -- sh -c 'exec /bin/bash 2>/dev/null || exec /bin/sh 2>/dev/null || exec bash 2>/dev/null || exec sh 2>/dev/null || (echo "No shell found"; exit 1)'
    }

    function kgp() {
      if [ $# -eq 0 ]; then
        kubecolor get pods --all-namespaces
      elif [ $# -eq 1 ]; then
        kubecolor get pods --all-namespaces | grep "$1"
      elif [ $# -eq 2 ]; then
        kubecolor get pods -n "$2" | grep "$1"
      else
        echo "Usage: kgp [pod-pattern] [namespace]"
        return 1
      fi
    }

    function dec() {
      if [ $# -ne 1 ]; then
        echo "Usage: dec <container_name>"
        return 1
      fi
      docker exec -it "$1" sh -c 'exec /bin/bash 2>/dev/null || exec /bin/sh 2>/dev/null || exec bash 2>/dev/null || exec sh 2>/dev/null || (echo "No shell found"; exit 1)'
    }

    function dps() {
      docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
    }

    function dclean() {
      echo "Cleaning up Docker resources..."
      docker system prune -f
      docker volume prune -f
      docker network prune -f
      echo "Docker cleanup complete!"
    }

    function dlf() {
      if [ $# -eq 0 ]; then
        echo "Usage: dlf <container_name_or_id>"
        return 1
      fi
      docker logs -f --timestamps "$1"
    }

    function pck() {
      if [ $# -ne 2 ]; then
        echo "Usage: pck <host> <port>"
        return 1
      fi
      nc -zv "$1" "$2"
    }

    function kexec-multi() {
      local dry_run=false
      local namespace=""
      local pod_pattern=""
      local command=""

      while [[ $# -gt 0 ]]; do
        case $1 in
          --dry-run)
            dry_run=true
            shift
            ;;
          *)
            if [[ -z "$namespace" ]]; then
              namespace="$1"
            elif [[ -z "$pod_pattern" ]]; then
              pod_pattern="$1"
            else
              command="$*"
              break
            fi
            shift
            ;;
        esac
      done

      if [[ -z "$namespace" || -z "$pod_pattern" || -z "$command" ]]; then
        echo "Usage: kexec-multi [--dry-run] <namespace> <pod-pattern> <command>"
        return 1
      fi

      echo "🔍 Finding pods matching pattern '$pod_pattern' in namespace '$namespace'..."
      local pods=$(kubectl get pods -n "$namespace" --no-headers | grep "$pod_pattern" | awk '{print $1}')

      if [[ -z "$pods" ]]; then
        echo "❌ No pods found matching pattern '$pod_pattern' in namespace '$namespace'"
        return 1
      fi

      local pod_count=$(echo "$pods" | wc -l | tr -d ' ')
      echo "📦 Found $pod_count pods:"
      echo "$pods" | sed 's/^/  - /'
      echo ""

      if [[ "$dry_run" == "true" ]]; then
        echo "🧪 DRY RUN - Commands that would be executed:"
        echo "$pods" | while read -r pod; do
          echo "  kubectl exec -n $namespace $pod -- $command"
        done
        return 0
      fi

      echo "🚀 Executing command: $command"
      echo "$pods" | while read -r pod; do
        echo ""
        echo "📍 Pod: $pod"
        local result=$(kubectl exec -n "$namespace" "$pod" -- sh -c "$command" 2>&1)
        local exit_code=$?
        if [[ $exit_code -eq 0 ]]; then
          echo "   ✅ Success:"
          echo "$result" | sed 's/^/   │ /'
        else
          echo "   ❌ Failed (exit code: $exit_code):"
          echo "$result" | sed 's/^/   │ /'
        fi
      done
      echo ""
      echo "✨ Execution completed for $pod_count pods"
    }

    function kg() { kubecolor get "$@"; }

    function kgn() {
      if [ $# -eq 0 ]; then
        kubecolor get nodes
      elif [ $# -eq 1 ]; then
        kubecolor get nodes "$1"
      else
        echo "Usage: kgn [node-name]"
        return 1
      fi
    }

    function kgnw() {
      if [ $# -eq 0 ]; then
        kubecolor get nodes -owide
      elif [ $# -eq 1 ]; then
        kubecolor get nodes "$1" -owide
      else
        echo "Usage: kgnw [node-name]"
        return 1
      fi
    }

    function kge() {
      if [ $# -eq 0 ]; then
        kubecolor get events -A
      elif [ $# -eq 1 ]; then
        kubecolor get events -A --field-selector="involvedObject.name=$1"
      else
        echo "Usage: kge [involvedObject-name]"
        return 1
      fi
    }

    function kgew() {
      if [ $# -eq 0 ]; then
        kubecolor get events -A -w
      elif [ $# -eq 1 ]; then
        kubecolor get events -A --field-selector="involvedObject.name=$1" -w
      else
        echo "Usage: kgew [involvedObject-name]"
        return 1
      fi
    }

    function kgpn() {
      if [ $# -ne 1 ]; then
        echo "Usage: kgpn <node-name>"
        return 1
      fi
      kubecolor get pods --all-namespaces --field-selector="spec.nodeName=$1"
    }

    function kgi() {
      if [ $# -eq 0 ]; then
        kubecolor get ingress --all-namespaces
      elif [ $# -eq 1 ]; then
        kubecolor get ingress --all-namespaces | grep "$1"
      elif [ $# -eq 2 ]; then
        kubecolor get ingress -n "$2" | grep "$1"
      else
        echo "Usage: kgi [ingress-pattern] [namespace]"
        return 1
      fi
    }

    function kgiw() {
      if [ $# -eq 0 ]; then
        kubecolor get ingress --all-namespaces -owide
      elif [ $# -eq 1 ]; then
        kubecolor get ingress --all-namespaces -owide | grep "$1"
      elif [ $# -eq 2 ]; then
        kubecolor get ingress -n "$2" -owide | grep "$1"
      else
        echo "Usage: kgiw [ingress-pattern] [namespace]"
        return 1
      fi
    }

    function kgd() {
      if [ $# -eq 0 ]; then
        kubecolor get deployments --all-namespaces
      elif [ $# -eq 1 ]; then
        kubecolor get deployments --all-namespaces | grep "$1"
      elif [ $# -eq 2 ]; then
        kubecolor get deployments -n "$2" | grep "$1"
      else
        echo "Usage: kgd [deployment-pattern] [namespace]"
        return 1
      fi
    }

    function kgdw() {
      if [ $# -eq 0 ]; then
        kubecolor get deployments --all-namespaces -owide
      elif [ $# -eq 1 ]; then
        kubecolor get deployments --all-namespaces -owide | grep "$1"
      elif [ $# -eq 2 ]; then
        kubecolor get deployments -n "$2" -owide | grep "$1"
      else
        echo "Usage: kgdw [deployment-pattern] [namespace]"
        return 1
      fi
    }

    function kgs() {
      if [ $# -eq 0 ]; then
        kubecolor get statefulsets --all-namespaces
      elif [ $# -eq 1 ]; then
        kubecolor get statefulsets --all-namespaces | grep "$1"
      elif [ $# -eq 2 ]; then
        kubecolor get statefulsets -n "$2" | grep "$1"
      else
        echo "Usage: kgs [statefulset-pattern] [namespace]"
        return 1
      fi
    }

    function kgsw() {
      if [ $# -eq 0 ]; then
        kubecolor get statefulsets --all-namespaces -owide
      elif [ $# -eq 1 ]; then
        kubecolor get statefulsets --all-namespaces -owide | grep "$1"
      elif [ $# -eq 2 ]; then
        kubecolor get statefulsets -n "$2" -owide | grep "$1"
      else
        echo "Usage: kgsw [statefulset-pattern] [namespace]"
        return 1
      fi
    }

    function kgpy() {
      if [ $# -eq 0 ]; then
        echo "Usage: kgpy <pod-name> [namespace]"
        return 1
      elif [ $# -eq 1 ]; then
        kubecolor get pod "$1" --all-namespaces -oyaml
      elif [ $# -eq 2 ]; then
        kubecolor get pod "$1" -n "$2" -oyaml
      else
        echo "Usage: kgpy <pod-name> [namespace]"
        return 1
      fi
    }

    function kgdy() {
      if [ $# -eq 0 ]; then
        echo "Usage: kgdy <deployment-name> [namespace]"
        return 1
      elif [ $# -eq 1 ]; then
        kubecolor get deployment "$1" --all-namespaces -oyaml
      elif [ $# -eq 2 ]; then
        kubecolor get deployment "$1" -n "$2" -oyaml
      else
        echo "Usage: kgdy <deployment-name> [namespace]"
        return 1
      fi
    }

    function kgny() {
      if [ $# -ne 1 ]; then
        echo "Usage: kgny <node-name>"
        return 1
      fi
      kubecolor get node "$1" -oyaml
    }

    function kgiy() {
      if [ $# -eq 0 ]; then
        echo "Usage: kgiy <ingress-name> [namespace]"
        return 1
      elif [ $# -eq 1 ]; then
        kubecolor get ingress "$1" --all-namespaces -oyaml
      elif [ $# -eq 2 ]; then
        kubecolor get ingress "$1" -n "$2" -oyaml
      else
        echo "Usage: kgiy <ingress-name> [namespace]"
        return 1
      fi
    }

    function kgsy() {
      if [ $# -eq 0 ]; then
        echo "Usage: kgsy <statefulset-name> [namespace]"
        return 1
      elif [ $# -eq 1 ]; then
        kubecolor get statefulset "$1" --all-namespaces -oyaml
      elif [ $# -eq 2 ]; then
        kubecolor get statefulset "$1" -n "$2" -oyaml
      else
        echo "Usage: kgsy <statefulset-name> [namespace]"
        return 1
      fi
    }

    function stn() {
      if [ $# -eq 0 ]; then
        echo "Usage: stn <pattern> [namespace]"
        return 1
      elif [ $# -eq 1 ]; then
        stern "$1" --all-namespaces
      elif [ $# -eq 2 ]; then
        stern "$1" -n "$2"
      else
        echo "Usage: stn <pattern> [namespace]"
        return 1
      fi
    }

    function kpfp() {
      if [ $# -lt 2 ]; then
        echo "Usage: kpfp <pod-name> <remote-port> [namespace]"
        return 1
      fi
      local pod_name="$1"
      local remote_port="$2"
      local namespace="''${3:-default}"
      local local_port=$((8000 + RANDOM % 2000))
      echo "🚀 Port forwarding: $pod_name ($namespace) $remote_port -> localhost:$local_port"
      kubectl port-forward -n "$namespace" "$pod_name" "$local_port:$remote_port"
    }

    function kpfs() {
      if [ $# -lt 2 ]; then
        echo "Usage: kpfs <service-name> <remote-port> [namespace]"
        return 1
      fi
      local service_name="$1"
      local remote_port="$2"
      local namespace="''${3:-default}"
      local local_port=$((8000 + RANDOM % 2000))
      echo "🚀 Port forwarding: svc/$service_name ($namespace) $remote_port -> localhost:$local_port"
      kubectl port-forward -n "$namespace" "svc/$service_name" "$local_port:$remote_port"
    }
  '';
}
